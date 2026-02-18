# n8n Web Server Health Monitoring Lab with AI

## Lab Overview

Learn n8n automation by building an AI-powered web server health monitoring system. This 45-minute hands-on lab teaches you how to use n8n with Ollama (local LLM) to automatically monitor and fix nginx web server issues.

**Duration:** 45 minutes
**Level:** Beginner (no coding required)
**Focus:** AI-powered infrastructure automation

## What You'll Learn

An AI agent that:
1. **Monitors** nginx web server status
2. **Detects** when the service is down
3. **Analyzes** logs and system state using Ollama LLM
4. **Remediates** by automatically restarting nginx
5. **Reports** results via chat interface

## Prerequisites

- ✅ Azure account (free tier works)
- ✅ Web browser (Chrome, Firefox, or Edge)
- ✅ Basic Linux command knowledge

---

## Quick Start

### Step 1: Open Azure Cloud Shell

1. Go to [portal.azure.com](https://portal.azure.com)
2. Click the **Cloud Shell** icon (>_) in the top menu bar
3. Select **Bash** environment
4. Wait for initialization

### Step 2: Clone Repository

```bash
git clone https://github.com/deanl1982/Whey-AI-Man.git
cd Whey-AI-Man/02-n8n-byo-lab
ls -la
```

### Step 3: Configure Terraform

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with nano
nano terraform.tfvars
```

**Update these values:**
```hcl
admin_password = "YourSecurePassword123!"  # ⚠️ CHANGE THIS!
vm_count = 1                                # 1 for demo, N for participants
resource_group_name = "rg-n8n-lab"         # Make it unique
```

**Optional - Change VM size or candidate regions:**

The default VM size is `Standard_D4s_v3` (4 vCPU, 16GB RAM). During deployment, Terraform automatically checks SKU availability across multiple candidate regions and selects the **best region based on availability and cost**. Your preferred region (`location`) is used as a tiebreaker when costs are equal.

You can customise this behaviour in `terraform.tfvars`:
```hcl
# Preferred region (used as tiebreaker when costs are equal)
location = "uksouth"

# Regions to check for availability and cost (best one is selected automatically)
candidate_regions = ["uksouth", "ukwest", "northeurope", "westeurope"]

# VM size (change if the default is not available in any candidate region)
vm_size = "Standard_D4s_v3"
```

> **Tip:** After `terraform apply`, the output will show which region was selected and the estimated hourly cost.

💾 **Save:** `Ctrl+O` then `Enter`
❌ **Exit:** `Ctrl+X`

### Step 4: Deploy VM

```bash
# Initialize Terraform
terraform init

# Deploy (takes ~5 minutes)
terraform apply
```

Type **`yes`** when prompted.

### Step 5: Get VM Details

```bash
terraform output vm_info
```

**Example output:**
```
vm_info = {
  "lab-vm-1" = {
    "n8n_url"  = "http://20.90.123.45:5678"
    "public_ip" = "20.90.123.45"
    "ssh"      = "ssh adminuser@20.90.123.45"
  }
}
```

📋 **Copy your VM IP address!**

### Step 6: Connect to VM and Run Setup

```bash
# SSH to your VM (from Cloud Shell)
ssh adminuser@<YOUR_VM_IP>
# Enter the password you set in terraform.tfvars

# Once connected, clone repo on the VM
git clone https://github.com/deanl1982/Whey-AI-Man.git
cd Whey-AI-Man/02-n8n-byo-lab

# Make script executable
chmod +x setup-lab-vm.sh

# Run setup (takes ~15 minutes)
./setup-lab-vm.sh
```

⏱️ **Setup installs:**
- Docker
- n8n (workflow automation)
- nginx (web server)
- Ollama + llama3.2 model (~2GB)

☕ **Grab a coffee while it downloads!**

### Step 7: Verify Installation

```bash
# Check everything is running
sudo docker ps                 # Should show n8n container
ollama list                    # Should show llama3.2
sudo systemctl status nginx    # Should show nginx active
```

✅ All services should be running!

---

## Using the Lab

### Step 8: Access n8n

Open your web browser to: **`http://<YOUR_VM_IP>:5678`**

You'll see the n8n welcome screen.

### Step 9: Import Workflows

1. In n8n, click **"Workflows"** in the left sidebar
2. Click **"Add workflow"** dropdown → **"Import from file"**
3. Import these two files (they're in the `n8n-files/` directory):
   - **SSH-Tools.json** (import first)
   - **Web Server Health Agent.json** (import second)

**Note:** You'll need to download these files from GitHub or copy them from the repo:
```bash
# On your local machine (not VM)
# Download from: https://github.com/deanl1982/Whey-AI-Man/tree/main/02-n8n-byo-lab/n8n-files
```

### Step 10: Configure SSH Credentials

The SSH-Tools workflow needs SSH credentials to execute commands:

1. In n8n, go to **"Credentials"** (left sidebar)
2. Click **"Add Credential"**
3. Search for **"SSH"** and select **"SSH (Password)"**
4. Configure:
   - **Name:** "SSH Password account"
   - **Host:** `localhost`
   - **Port:** `22`
   - **Username:** `adminuser` (or your VM username)
   - **Password:** Your VM password
5. Click **"Save"**

### Step 11: Activate Web Server Health Agent

1. Open the **"Web Server Health Agent"** workflow
2. Click the toggle at the top right to **activate** it
3. The chat interface should now appear

---

## Testing the Lab

### Test 1: Check Website Status

In the n8n chat interface, type:
```
Is the website up?
```

The AI agent will:
- Check http://localhost/
- Report that nginx is running
- Show you the "Welcome to Whey-AI, Man!" message

### Test 2: Simulate nginx Failure

SSH to your VM and stop nginx:
```bash
sudo systemctl stop nginx
```

In the n8n chat, ask again:
```
Is the website up?
```

The AI agent will:
- Detect nginx is down
- Analyze the situation
- Automatically restart nginx
- Report success!

### Test 3: Verify Auto-Restart

```bash
# Check nginx is running again
sudo systemctl status nginx
```

🎉 **Success!** The AI agent detected the failure and fixed it automatically!

---

## What's Happening Behind the Scenes?

The **Web Server Health Agent** workflow:

1. **Chat Trigger** - Receives your message
2. **Ollama Chat Model** - Uses llama3.2 to understand intent
3. **Check Website Tool** - Makes HTTP request to http://localhost/
4. **SSH Command Tool** - Executes system commands (via SSH-Tools workflow)
5. **AI Agent** - Orchestrates everything and decides what to do

When nginx is down, the AI:
- Detects the HTTP request fails
- Checks nginx status: `sudo systemctl status nginx`
- Sees it's stopped
- Runs: `sudo systemctl start nginx`
- Verifies it's working
- Reports back to you!

---

## Architecture

```
┌─────────────────────────────────────────┐
│  Your Browser                            │
│  - Access n8n web UI                     │
│  - Chat with AI agent                    │
└────────────────┬────────────────────────┘
                 │
                 │ HTTP (port 5678)
                 │
┌────────────────▼────────────────────────┐
│  Azure VM (Standard_D4s_v3)              │
│                                          │
│  ┌──────────────────────────────────┐  │
│  │  n8n (Docker container)           │  │
│  │  - Web Server Health Agent        │  │
│  │  - SSH-Tools workflow             │  │
│  └──────────┬───────────────────────┘  │
│             │                            │
│  ┌──────────▼───────────────────────┐  │
│  │  Ollama (native service)          │  │
│  │  - llama3.2 model (~2GB)          │  │
│  │  - Port 11434                     │  │
│  └──────────────────────────────────┘  │
│                                          │
│  ┌──────────────────────────────────┐  │
│  │  nginx web server                 │  │
│  │  - Serves on port 80              │  │
│  │  - Custom welcome page            │  │
│  └──────────────────────────────────┘  │
└──────────────────────────────────────────┘
```

---

## Cleanup

When finished, destroy all resources to avoid charges:

```bash
# Exit SSH (back to Cloud Shell)
exit

# Navigate to lab directory
cd ~/Whey-AI-Man/02-n8n-byo-lab

# Destroy everything
terraform destroy
```

Type **`yes`** when prompted.

**Cost:** ~£0.14 per VM for 45-minute session

---

## Troubleshooting

### Can't access n8n?
```bash
# Check VM is running
az vm list -g <your-resource-group>

# Verify n8n container
sudo docker ps

# Restart if needed
sudo docker restart n8n
```

### Ollama not working?
```bash
# Check service
sudo systemctl status ollama

# Restart if needed
sudo systemctl restart ollama

# Test manually
curl http://localhost:11434/api/generate -d '{"model":"llama3.2","prompt":"test","stream":false}'
```

### nginx issues?
```bash
# Check status
sudo systemctl status nginx

# View logs
sudo journalctl -u nginx -f

# Restart
sudo systemctl restart nginx
```

### SSH credentials not working in n8n?
- Verify username/password are correct
- Make sure host is set to `localhost`
- Port should be `22`
- Test SSH manually: `ssh adminuser@localhost`

---

## Cost Information

**VM Size:** Standard_D4s_v3
- 4 vCPUs
- 16 GB RAM
- ~$0.192/hour (UK South region)

**Lab Session (45 mins):**
- Single VM: ~$0.14
- 10 VMs: ~$1.40

**Remember to run `terraform destroy` when finished!**

---

## Translating to Azure

This pattern applies to:
- **Azure VMs:** Monitor services, auto-restart on failure
- **App Service:** Health check web apps, restart if needed
- **Container Instances:** Monitor containers, remediate issues
- **AKS:** Pod health monitoring and auto-healing

Same workflow pattern, just different targets!

---

## Credits

This lab is part of the **Whey-AI-Man** project - making AI literacy accessible through hands-on education.

**Technologies:**
- [n8n](https://n8n.io) - Workflow automation platform
- [Ollama](https://ollama.com) - Local LLM inference
- [llama3.2](https://ollama.com/library/llama3.2) - Meta's language model
- [nginx](https://nginx.org) - Web server
- [Azure](https://azure.microsoft.com) - Cloud infrastructure

---

## Next Steps

1. **Export your workflows** for future use
2. **Try extending the agent** with more tools (check disk space, monitor logs)
3. **Adapt for your environment** - monitor your actual services
4. **Build more AI agents** for other infrastructure tasks

**Questions?** Open an issue on GitHub!

---

**Ready to automate? Let's go!** 🚀
