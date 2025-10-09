# Whey-AI-Man

## n8n Lab Environment

This repository contains infrastructure as code (IaC) and setup scripts for deploying n8n in an Azure environment. n8n is a workflow automation tool that allows you to connect different services and automate tasks.

## Project Structure

```plaintext
├── 01-Build-N8N/
│   ├── n8n-vm.tf       # Terraform configuration for Azure infrastructure
│   └── setup-n8n.sh    # Shell script for installing and configuring n8n
```

## Prerequisites

- Azure CLI installed and configured
- Terraform installed
- Access to an Azure subscription
- Basic understanding of Docker and networking concepts

## Infrastructure Components

The project sets up the following Azure resources:

- Resource Group
- Virtual Network with a dedicated subnet
- Public IP address
- Network Security Group
- Virtual Machine (with necessary security rules)

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
   - Connect to the VM using SSH
   - Run the setup script:

     ```bash
     ./setup-n8n.sh
     ```

## Architecture

The setup creates a VM in Azure with:

- Docker for containerization
- n8n running in a Docker container
- Nginx as a reverse proxy
- Persistent volume for n8n data
- Docker network for container communication

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