## n8n Lab Environment

This repository contains infrastructure as code (IaC) and setup scripts for deploying n8n in an Azure environment. n8n is a workflow automation tool that allows you to connect different services and automate tasks.

## Project Structure

```plaintext
├── 01-Build-N8N/
│   ├── n8n-vm.tf       # Terraform configuration for Azure infrastructure
│   └── setup-vm.sh     # Shell script for installing and configuring n8n and dependencies
```

## Prerequisites

- Azure CLI installed and configured
- Terraform installed
- Access to an Azure subscription
- Basic understanding of Docker and networking concepts

## Infrastructure Components

The project sets up the following Azure resources:

- Resource Group (named 'rg-whey-ai-man-n8n' by default)
- Virtual Network with a dedicated subnet (10.0.0.0/16 network space)
- Public IP address (Dynamic allocation)
- Network Security Group with rules for:
  - SSH (port 22)
  - HTTP (port 80)
  - HTTPS (port 443)
  - n8n (port 5678)
- Ubuntu 18.04 LTS Virtual Machine (Standard_B2s size)

## Quick Start

1. **Initialize Terraform**

   ```bash
   cd 01-Build-N8N
   terraform init
   ```

2. **Deploy Azure Infrastructure**

   ```bash
   terraform plan
   terraform apply
   ```

3. **Configure n8n**
   - Connect to the VM using SSH (password: YourSecurePassword123!)
   - Run the setup script:

     ```bash
     sudo chmod +x setup-vm.sh
     ./setup-vm.sh
     ```

   After setup completes:
   - n8n will be available at `http://your-vm-ip:5678`
   - Nginx will be configured and running
   - UFW firewall will be enabled with proper rules

## Architecture

The setup creates a VM in Azure with:

- Docker for containerization
- n8n running in a Docker container with persistence
- Nginx installed directly on the system (not containerized)
- UFW (Uncomplicated Firewall) enabled with Nginx rules
- Persistent volume for n8n data

## Network Configuration

- n8n runs on port 5678 (internal)
- Nginx handles HTTP(80) and HTTPS(443) traffic
- Custom Docker network 'web' for internal communication

## Security Considerations

- Network Security Group rules control inbound traffic
- n8n is only accessible through Nginx reverse proxy
- Docker containers are isolated using a dedicated network

## Customization

To modify the default configuration:

1. **Azure Resources**: Edit `n8n-vm.tf` to change:
   - Resource group name
   - Location
   - Network configurations
   - VM size

2. **n8n Setup**: Modify `setup-n8n.sh` to:
   - Change Docker container configurations
   - Update environment variables
   - Modify networking settings

## Contributing

Feel free to submit issues and enhancement requests!

## License

[MIT License](LICENSE)
