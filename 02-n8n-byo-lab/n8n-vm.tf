# Terraform configuration for Build Your Own n8n + AI Agent Lab
# Provisions Azure VM with n8n, Ollama, and llama3.2

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Variables
variable "resource_group_name" {
    default     = "rg-n8n-byo-lab"
    description = "Resource group for n8n BYO lab VMs"
}

variable "location" {
    default     = "uksouth"
    description = "Azure region for deployment"
}

variable "admin_username" {
    default     = "adminuser"
    description = "Admin username for VM login"
}

variable "admin_password" {
    default     = "YourSecurePassword123!"
    description = "Admin password - CHANGE THIS before deploying!"
    sensitive   = true
}

variable "vm_count" {
    default     = 1
    description = "Number of VMs to create (set to number of lab participants)"
}

variable "vm_size" {
    default     = "Standard_D4s_v3"
    description = "VM size/SKU - 4 vCPU, 16GB RAM recommended for Ollama/llama3.2"
}

# Check VM SKU availability in the selected region
# Uses Azure CLI (available in Cloud Shell) to verify the SKU is not restricted
data "external" "sku_check" {
    program = ["bash", "${path.module}/check-sku.sh"]

    query = {
        location = var.location
        vm_size  = var.vm_size
    }
}

# Resource Group
resource "azurerm_resource_group" "rg" {
    name     = var.resource_group_name
    location = var.location

    tags = {
        Environment = "Lab"
        Purpose     = "n8n AI Agent Lab"
        Project     = "Whey-AI-Man"
    }
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
    name                = "n8n-byo-lab-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = {
        Environment = "Lab"
    }
}

# Subnet
resource "azurerm_subnet" "subnet" {
    name                 = "lab-subnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}

# Public IP (one per VM)
resource "azurerm_public_ip" "pip" {
    count               = var.vm_count
    name                = "lab-vm-${count.index + 1}-pip"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
    sku                 = "Standard"

    tags = {
        Environment = "Lab"
        VM          = "lab-vm-${count.index + 1}"
    }
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
    name                = "lab-nsg"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    # SSH Access
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    # HTTP Access (for nginx if needed)
    security_rule {
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    # HTTPS Access
    security_rule {
        name                       = "HTTPS"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    # n8n Web Interface
    security_rule {
        name                       = "N8N"
        priority                   = 1004
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5678"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        Environment = "Lab"
    }
}

# Network Interface (one per VM)
resource "azurerm_network_interface" "nic" {
    count               = var.vm_count
    name                = "lab-vm-${count.index + 1}-nic"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.pip[count.index].id
    }

    tags = {
        Environment = "Lab"
        VM          = "lab-vm-${count.index + 1}"
    }
}

# Connect NSG to NIC
resource "azurerm_network_interface_security_group_association" "nsg_association" {
    count                     = var.vm_count
    network_interface_id      = azurerm_network_interface.nic[count.index].id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

# Virtual Machine (one per participant)
resource "azurerm_linux_virtual_machine" "vm" {
    count               = var.vm_count
    name                = "lab-vm-${count.index + 1}"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    size                = var.vm_size  # 4 vCPU, 16GB RAM - Optimal for Ollama/llama3.2
    admin_username      = var.admin_username

    network_interface_ids = [
        azurerm_network_interface.nic[count.index].id
    ]

    admin_password                  = var.admin_password
    disable_password_authentication = false

    # Fail early if the selected VM SKU is not available in the target region
    lifecycle {
        precondition {
            condition     = data.external.sku_check.result.available == "true"
            error_message = "VM size '${var.vm_size}' is not available in region '${var.location}'. Run 'az vm list-skus --location ${var.location} --output table' to see available sizes, or set a different vm_size in terraform.tfvars."
        }
    }

    os_disk {
        name                 = "lab-vm-${count.index + 1}-osdisk"
        caching              = "ReadWrite"
        storage_account_type = "Premium_LRS"
        disk_size_gb         = 64  # Increased for Ollama model
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-focal"
        sku       = "20_04-lts-gen2"
        version   = "latest"
    }

    # Custom script to run setup automatically (optional)
    # Uncomment if you want automatic setup
    # custom_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {}))

    tags = {
        Environment = "Lab"
        VM          = "lab-vm-${count.index + 1}"
        Purpose     = "n8n AI Agent Lab"
    }
}

# Auto-shutdown schedule (9pm daily) to prevent forgotten VMs running up costs
resource "azurerm_dev_test_global_vm_shutdown_schedule" "auto_shutdown" {
    count              = var.vm_count
    virtual_machine_id = azurerm_linux_virtual_machine.vm[count.index].id
    location           = azurerm_resource_group.rg.location
    enabled            = true

    daily_recurrence_time = "2100"
    timezone              = "GMT Standard Time"

    notification_settings {
        enabled = false
    }

    tags = {
        Environment = "Lab"
    }
}

# Outputs
output "vm_info" {
    description = "VM connection information"
    value = {
        for i in range(var.vm_count) : "lab-vm-${i + 1}" => {
            public_ip = azurerm_public_ip.pip[i].ip_address
            n8n_url   = "http://${azurerm_public_ip.pip[i].ip_address}:5678"
            ssh       = "ssh ${var.admin_username}@${azurerm_public_ip.pip[i].ip_address}"
        }
    }
}

output "resource_group" {
    description = "Resource group name"
    value       = azurerm_resource_group.rg.name
}

output "setup_instructions" {
    description = "Next steps after VM is created"
    value = <<-EOT

    ╔════════════════════════════════════════════════════════════╗
    ║  n8n AI Agent Lab - VMs Ready!                             ║
    ╚════════════════════════════════════════════════════════════╝

    Next steps:

    1. SSH to VM(s):
       See 'vm_info' output above for SSH commands

    2. Copy lab files to VM:
       scp -r ../02-n8n-byo-lab ${var.admin_username}@<VM_IP>:/home/${var.admin_username}/

    3. Run setup script on VM:
       cd /home/${var.admin_username}/02-n8n-byo-lab
       chmod +x setup-lab-vm.sh
       ./setup-lab-vm.sh

    4. Wait ~15 minutes for Ollama model download (~2GB)

    5. Access n8n:
       See 'vm_info' output for n8n URLs

    6. Start building your AI agents!

    NOTE: VMs will auto-shutdown at 9pm (GMT) daily to prevent
    unexpected costs. You can restart them from the Azure portal
    if needed.

    ╔════════════════════════════════════════════════════════════╗
    ║  Cleanup when done: terraform destroy                      ║
    ╚════════════════════════════════════════════════════════════╝

    EOT
}
