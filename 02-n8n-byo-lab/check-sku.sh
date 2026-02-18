#!/bin/bash
# check-sku.sh - Validates VM SKU availability in an Azure region
# Used by Terraform data "external" to fail early if SKU is restricted
#
# Expects JSON input on stdin with keys: location, vm_size
# Returns JSON output with key: available ("true" or "false")

set -e

# Read input from Terraform (passed as JSON on stdin)
INPUT=$(cat)
LOCATION=$(echo "$INPUT" | jq -r '.location')
VM_SIZE=$(echo "$INPUT" | jq -r '.vm_size')

# Query Azure for SKU restrictions in the target region
TOTAL=$(az vm list-skus \
    --location "$LOCATION" \
    --size "$VM_SIZE" \
    --query "length(@)" \
    -o tsv 2>/dev/null || echo "0")

RESTRICTED=$(az vm list-skus \
    --location "$LOCATION" \
    --size "$VM_SIZE" \
    --query "[?restrictions[?reasonCode=='NotAvailableForSubscription']] | length(@)" \
    -o tsv 2>/dev/null || echo "0")

# SKU is available if it exists and is not fully restricted
if [ "$TOTAL" = "0" ] || [ "$RESTRICTED" = "$TOTAL" ]; then
    echo "{\"available\": \"false\"}"
else
    echo "{\"available\": \"true\"}"
fi
