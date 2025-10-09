# Provider configuration
provider "azurerm" {
    features {}
}

# Variables
variable "resource_group_name" {
    default = "rg-whey-ai-man-n8n"
}

variable "location" {
    default = "uksouth"
}

variable "admin_username" {
    default = "adminuser"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
    name     = var.resource_group_name
    location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
    name                = "n8n-vnet"
    address_space       = ["10.0.0.0/16"]
    location           = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
    name                 = "n8n-subnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "pip" {
    name                = "n8n-pip"
    location           = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Dynamic"
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
    name                = "n8n-nsg"
    location           = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                    = "Allow"
        protocol                  = "Tcp"
        source_port_range         = "*"
        destination_port_range    = "22"
        source_address_prefix     = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                    = "Allow"
        protocol                  = "Tcp"
        source_port_range         = "*"
        destination_port_range    = "80"
        source_address_prefix     = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPS"
        priority                   = 1003
        direction                  = "Inbound"
        access                    = "Allow"
        protocol                  = "Tcp"
        source_port_range         = "*"
        destination_port_range    = "443"
        source_address_prefix     = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "N8N"
        priority                   = 1004
        direction                  = "Inbound"
        access                    = "Allow"
        protocol                  = "Tcp"
        source_port_range         = "*"
        destination_port_range    = "5678"
        source_address_prefix     = "*"
        destination_address_prefix = "*"
    }
}

# Network Interface
resource "azurerm_network_interface" "nic" {
    name                = "n8n-nic"
    location           = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.pip.id
    }
}

# Connect NSG to NIC
resource "azurerm_network_interface_security_group_association" "nsg_association" {
    network_interface_id      = azurerm_network_interface.nic.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
    name                = "n8n-vm"
    resource_group_name = azurerm_resource_group.rg.name
    location           = azurerm_resource_group.rg.location
    size               = "Standard_B2s"
    admin_username     = var.admin_username

    network_interface_ids = [
        azurerm_network_interface.nic.id
    ]

    admin_password = "YourSecurePassword123!"
    disable_password_authentication = false

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }
}

# Output the public IP
output "public_ip_address" {
    value = azurerm_public_ip.pip.ip_address
}