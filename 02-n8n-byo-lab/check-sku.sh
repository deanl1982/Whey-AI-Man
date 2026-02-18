#!/bin/bash
# check-sku.sh - Checks VM SKU availability across multiple Azure regions
# and selects the best region based on availability and cost.
#
# Used by Terraform data "external" resource.
#
# Expects JSON input on stdin with keys:
#   vm_size    - The VM SKU to check (e.g. "Standard_D4s_v3")
#   regions    - Comma-separated list of candidate regions (e.g. "uksouth,ukwest,northeurope")
#   preferred  - Preferred region (used as tiebreaker if costs are equal)
#
# Returns JSON output with keys:
#   best_region - The recommended region
#   price       - Estimated hourly price (USD) or "unknown"
#   available   - "true" if at least one region has the SKU available

set -e

# Read input from Terraform
INPUT=$(cat)
VM_SIZE=$(echo "$INPUT" | jq -r '.vm_size')
REGIONS=$(echo "$INPUT" | jq -r '.regions')
PREFERRED=$(echo "$INPUT" | jq -r '.preferred')

# Split regions into array
IFS=',' read -ra REGION_LIST <<< "$REGIONS"

BEST_REGION=""
BEST_PRICE=999999
FOUND_ANY="false"

for REGION in "${REGION_LIST[@]}"; do
    # Trim whitespace
    REGION=$(echo "$REGION" | xargs)

    # Check if SKU exists and is not restricted in this region
    TOTAL=$(az vm list-skus \
        --location "$REGION" \
        --size "$VM_SIZE" \
        --query "length(@)" \
        -o tsv 2>/dev/null || echo "0")

    RESTRICTED=$(az vm list-skus \
        --location "$REGION" \
        --size "$VM_SIZE" \
        --query "[?restrictions[?reasonCode=='NotAvailableForSubscription']] | length(@)" \
        -o tsv 2>/dev/null || echo "0")

    # Skip if SKU not available
    if [ "$TOTAL" = "0" ] || [ "$RESTRICTED" = "$TOTAL" ]; then
        continue
    fi

    FOUND_ANY="true"

    # Get retail price for this SKU in this region via Azure Retail Prices API
    # Map Azure CLI region names to ARM region names for the pricing API
    PRICE=$(curl -s "https://prices.azure.com/api/retail/prices?\$filter=armRegionName eq '${REGION}' and armSkuName eq '${VM_SIZE}' and priceType eq 'Consumption' and serviceName eq 'Virtual Machines'" \
        2>/dev/null | jq -r '[.Items[] | select(.type == "Consumption" and (.meterName | test("Spot") | not) and (.skuName | test("Low Priority") | not)) | .retailPrice] | min // 999999')

    # Handle failed price lookups
    if [ -z "$PRICE" ] || [ "$PRICE" = "null" ]; then
        PRICE=999999
    fi

    # Use awk for float comparison
    IS_BETTER=$(awk -v price="$PRICE" -v best="$BEST_PRICE" 'BEGIN {
        if (price < best) print "yes"
        else if (price == best) print "tie"
        else print "no"
    }')

    if [ "$IS_BETTER" = "yes" ]; then
        BEST_REGION="$REGION"
        BEST_PRICE="$PRICE"
    elif [ "$IS_BETTER" = "tie" ] && [ "$REGION" = "$PREFERRED" ]; then
        # Prefer the user's preferred region if costs are equal
        BEST_REGION="$REGION"
        BEST_PRICE="$PRICE"
    fi
done

# Format price for output
if [ "$BEST_PRICE" = "999999" ]; then
    DISPLAY_PRICE="unknown"
else
    DISPLAY_PRICE="$BEST_PRICE"
fi

if [ "$FOUND_ANY" = "true" ]; then
    echo "{\"best_region\": \"${BEST_REGION}\", \"price\": \"${DISPLAY_PRICE}\", \"available\": \"true\"}"
else
    echo "{\"best_region\": \"\", \"price\": \"unknown\", \"available\": \"false\"}"
fi
