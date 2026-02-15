# Lab Deployment Guide

Quick guide to deploy VMs for the Disk Space Cleanup Lab using Terraform.

---

## Prerequisites

- Azure CLI installed and logged in
- Terraform installed (v1.0+)
- Azure subscription with permissions to create resources

---

## Quick Start

### 1. Login to Azure

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### 2. Configure Terraform Variables

```bash
# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars
nano terraform.tfvars
```

**Important:** Change at least:
- `admin_password` - Set a secure password!
- `vm_count` - Number of VMs to create (1 for demo, N for participants)

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Create resources (takes ~5 minutes)
terraform apply

# Type 'yes' when prompted
```

### 4. Copy Lab Files to VM(s)

After Terraform completes, you'll see output with IP addresses.

**For single VM:**
```bash
# Copy entire lab directory to VM
scp -r . adminuser@<VM_IP>:/home/adminuser/disk-cleanup-lab/
```

**For multiple VMs:**
```bash
# Get all IPs from Terraform output
terraform output -json vm_info | jq -r '.[] | .public_ip'

# Copy to each VM (example script)
for ip in $(terraform output -json vm_info | jq -r '.[] | .public_ip'); do
    echo "Copying to $ip..."
    scp -r . adminuser@$ip:/home/adminuser/disk-cleanup-lab/
done
```

### 5. Run Setup on Each VM

**SSH to VM:**
```bash
ssh adminuser@<VM_IP>
```

**Run setup script:**
```bash
cd /home/adminuser/disk-cleanup-lab
chmod +x setup-lab-vm.sh
./setup-lab-vm.sh
```

⏱️ **Wait ~15 minutes** for Ollama to download Llama2 model (~4GB)

### 6. Verify Installation

```bash
# Check n8n is running
docker ps

# Check Ollama
ollama list

# Test Ollama
./sample-data/ollama-test.sh
```

### 7. Access n8n

Open browser to: `http://<VM_IP>:5678`

---

## Terraform Outputs

After `terraform apply`, you'll see:

```
Outputs:

vm_info = {
  "lab-vm-1" = {
    "n8n_url" = "http://20.90.123.45:5678"
    "public_ip" = "20.90.123.45"
    "ssh" = "ssh adminuser@20.90.123.45"
  }
}

resource_group = "rg-disk-cleanup-lab"

setup_instructions = <<-EOT
[Instructions displayed]
EOT
```

**Save these for participants!**

---

## Multiple Participant Setup

### Option 1: Pre-Deploy All VMs

**terraform.tfvars:**
```hcl
vm_count = 10  # For 10 participants
```

**Deploy:**
```bash
terraform apply
```

**Result:** 10 VMs created, named `lab-vm-1` through `lab-vm-10`

### Option 2: Share Credentials

Create a handout for participants:

```
╔═══════════════════════════════════════════════╗
║  Disk Cleanup Lab - Your VM Details          ║
╠═══════════════════════════════════════════════╣
║  Name:     lab-vm-3                           ║
║  IP:       20.90.123.47                       ║
║  SSH:      ssh adminuser@20.90.123.47         ║
║  Password: [provided separately]              ║
║  n8n URL:  http://20.90.123.47:5678          ║
╚═══════════════════════════════════════════════╝
```

---

## Cost Estimation

### VM Size: Standard_D4s_v3
- 4 vCPUs
- 16 GB RAM
- ~$0.192/hour (UK South region)

### Lab Session (45 mins)
- Single VM: ~$0.14
- 10 VMs: ~$1.40

### Full Day (8 hours, with setup/testing)
- Single VM: ~$1.54
- 10 VMs: ~$15.40

**Note:** Prices vary by region and Azure agreement.

### Why Standard_D4s_v3?
- ✅ 16GB RAM ensures smooth Llama2 operation
- ✅ 4 vCPUs for faster LLM inference
- ✅ Better multi-tasking (workflow + LLM)
- ✅ Participants won't experience slowdowns

---

## Troubleshooting

### Terraform Errors

**Error: "Resource group already exists"**
```bash
# Use different name in terraform.tfvars
resource_group_name = "rg-disk-cleanup-lab-v2"
```

**Error: "Subscription not found"**
```bash
# Check your Azure login
az account show
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### SSH Connection Issues

**Error: "Connection refused"**
- Wait a few minutes for VM to fully start
- Check NSG rules allow SSH (port 22)

**Error: "Permission denied"**
- Verify username and password
- Check admin_username in terraform.tfvars

### n8n Not Accessible

**Error: "Cannot reach http://VM_IP:5678"**
- Verify n8n container is running: `docker ps`
- Check NSG allows port 5678
- Restart container: `docker restart n8n`

---

## Cleanup After Lab

### Destroy All Resources

```bash
# Remove all VMs and infrastructure
terraform destroy

# Type 'yes' when prompted
```

This removes:
- All VMs
- Network interfaces
- Public IPs
- Virtual network
- Resource group

**Cost:** $0 after destruction

### Selective Cleanup

Keep infrastructure but stop VMs:

```bash
# Stop all VMs (keeps data, reduces cost to storage only)
az vm deallocate --ids $(az vm list -g rg-disk-cleanup-lab --query "[].id" -o tsv)

# Start again when needed
az vm start --ids $(az vm list -g rg-disk-cleanup-lab --query "[].id" -o tsv)
```

---

## Advanced: Automated Setup

### Option 1: Cloud-Init (Not Implemented Yet)

Create `cloud-init.yaml`:
```yaml
#cloud-init
package_update: true
package_upgrade: true

runcmd:
  - curl -fsSL https://get.docker.com | sh
  - curl -fsSL https://ollama.com/install.sh | sh
  # ... rest of setup
```

Uncomment in `n8n-vm.tf`:
```hcl
custom_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {}))
```

### Option 2: Remote-Exec Provisioner

Add to `n8n-vm.tf`:
```hcl
provisioner "remote-exec" {
  inline = [
    "curl -o setup.sh https://raw.githubusercontent.com/.../setup-lab-vm.sh",
    "chmod +x setup.sh",
    "./setup.sh"
  ]
}
```

---

## Security Best Practices

### For Production Use

1. **Use SSH Keys Instead of Password:**
```hcl
admin_ssh_key {
  username   = var.admin_username
  public_key = file("~/.ssh/id_rsa.pub")
}
disable_password_authentication = true
```

2. **Restrict NSG Rules:**
```hcl
source_address_prefix = "YOUR_IP/32"  # Only your IP
```

3. **Use Azure Key Vault for Secrets:**
```hcl
data "azurerm_key_vault_secret" "admin_password" {
  name         = "vm-admin-password"
  key_vault_id = data.azurerm_key_vault.kv.id
}
```

4. **Enable Boot Diagnostics:**
```hcl
boot_diagnostics {
  storage_account_uri = azurerm_storage_account.diag.primary_blob_endpoint
}
```

---

## Additional Resources

- [Terraform Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure VM Sizes](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes)
- [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)

---

## Summary Commands

```bash
# Complete deployment in one go
az login
cd 02-n8n-byo-lab
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars (change password and vm_count)
terraform init
terraform apply -auto-approve
# Wait for completion
# Copy lab files to VM(s)
# SSH and run setup-lab-vm.sh
# Start the lab!

# Cleanup when done
terraform destroy -auto-approve
```

---

*Return to [README](README.md) | [Lab Guide](lab-guide.md)*
