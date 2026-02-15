# Intelligent Disk Space Cleanup with n8n and AI

## Lab Overview

Welcome to this hands-on lab where you'll learn n8n automation fundamentals by building an intelligent disk space cleanup system powered by AI!

**Duration:** 45 minutes
**Level:** Beginner (no coding required)
**Focus:** Practical "break-fix" automation for infrastructure management

## What You'll Build

An automated workflow that:
1. **Monitors** disk space usage every 60 seconds
2. **Detects** when usage exceeds 85% threshold
3. **Analyzes** disk usage with AI (Ollama LLM)
4. **Remediates** by cleaning up old files automatically
5. **Verifies** disk space has been freed
6. **Notifies** with results

## Why This Matters

Disk space issues are a universal problem in infrastructure management:
- Web server logs filling up `/var/log`
- Docker image cache on build servers
- Temp files from data processing jobs
- Database transaction logs growing unchecked

This lab teaches you how to automate monitoring and remediation, saving you from 2 AM "disk full" alerts!

## Learning Objectives

By the end of this lab, you will:
- ✅ Create n8n workflows from scratch
- ✅ Use schedule triggers for monitoring tasks
- ✅ Execute shell commands via n8n
- ✅ Integrate Ollama LLM for intelligent analysis
- ✅ Write prompts for DevOps decision-making
- ✅ Implement conditional logic (IF nodes)
- ✅ Apply the pattern: monitor → detect → analyze → remediate → verify
- ✅ Translate this to Azure VM monitoring scenarios

## Prerequisites

**For Lab Participants:**
- ✅ Azure account (free tier works!)
- ✅ Web browser (Chrome, Firefox, Edge)
- ✅ Basic Linux command knowledge (ls, cd, rm)

**No Installation Required:**
- ✅ Uses Azure Cloud Shell (browser-based terminal)
- ✅ Terraform pre-installed in Cloud Shell
- ✅ Azure CLI pre-configured

**No Coding Required:**
- ✅ Visual workflow builder (drag and drop)
- ✅ Copy/paste commands provided
- ✅ All scripts included

## Quick Start

### 🚀 Deploy Lab VMs with Azure Cloud Shell (Recommended)

**Perfect for lab sessions - no local setup required!**

#### Step 1: Open Azure Cloud Shell
1. Go to [portal.azure.com](https://portal.azure.com)
2. Click the **Cloud Shell** icon (>_) in the top menu bar
3. Select **Bash** environment
4. Wait for Cloud Shell to initialize

#### Step 2: Clone This Repository
```bash
# Clone from GitHub
git clone https://github.com/deanl1982/Whey-AI-Man.git

# Navigate to lab directory
cd Whey-AI-Man/02-n8n-byo-lab

# List files to verify
ls -la
```

#### Step 3: Configure Terraform Variables
```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with nano (recommended for beginners)
nano terraform.tfvars
```

**Required Changes:**
```hcl
# In terraform.tfvars, update these:
admin_password = "ChangeThisPassword123!"  # ⚠️ CHANGE THIS!
vm_count = 1                                # 1 for demo, N for participants
resource_group_name = "rg-my-disk-lab"     # Change if needed
```

💾 **Save:** Press `Ctrl+O`, then `Enter`
❌ **Exit:** Press `Ctrl+X`

**Alternative editors in Cloud Shell:**
- `nano terraform.tfvars` (easiest, recommended)
- `vi terraform.tfvars` (if you prefer vi/vim)
- Click the **{ }** editor icon in Cloud Shell toolbar

#### Step 4: Deploy with Terraform
```bash
# Initialize Terraform (downloads Azure provider)
terraform init

# Preview what will be created
terraform plan

# Deploy the infrastructure
terraform apply
```

Type **`yes`** when prompted.

⏱️ **Deployment takes ~5 minutes**

#### Step 5: Get VM Access Information
```bash
# View all VM details
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

**📋 Copy these details for participants!**

#### Step 6: Connect to VM and Run Setup
```bash
# SSH to your VM (from Cloud Shell)
ssh adminuser@<VM_IP>
# Use the password you set in terraform.tfvars

# Once connected, clone the repo on the VM
git clone https://github.com/deanl1982/Whey-AI-Man.git
cd Whey-AI-Man/02-n8n-byo-lab

# Make setup script executable
chmod +x setup-lab-vm.sh

# Run the setup
./setup-lab-vm.sh
```

⏱️ **Wait ~15 minutes** for:
- Docker installation
- n8n container setup
- Ollama installation
- Llama2 model download (~4GB)

#### Step 7: Verify Installation
```bash
# Check Docker is running
docker ps

# Check Ollama has Llama2
ollama list

# Test Ollama
./sample-data/ollama-test.sh
```

#### Step 8: Access n8n Web Interface
Open your browser to: `http://<VM_IP>:5678`

🎉 **Lab is ready! Start building your workflow!**

---

### 🧹 Cleanup After Lab

When finished, destroy all resources to avoid charges:

```bash
# Back in Azure Cloud Shell
cd ~/Whey-AI-Man/02-n8n-byo-lab

# Destroy all infrastructure
terraform destroy
```

Type **`yes`** when prompted.

---

### 💡 Tips for Lab Sessions

**For Multiple Participants:**
```hcl
# In terraform.tfvars
vm_count = 10  # Creates 10 VMs (one per participant)
```

**Cost for 10 participants (45 min):** ~£1.40

**Create Participant Handout:**
```
╔═══════════════════════════════════════════════╗
║  Your Lab Environment                         ║
╠═══════════════════════════════════════════════╣
║  VM:       lab-vm-3                           ║
║  IP:       20.90.123.47                       ║
║  SSH:      ssh adminuser@20.90.123.47         ║
║  Password: [provided separately]              ║
║  n8n:      http://20.90.123.47:5678          ║
╚═══════════════════════════════════════════════╝
```

---

### 💻 Alternative: Manual Setup (If You Have Your Own VM)

If you already have an Ubuntu VM with Docker:

```bash
# Install n8n
docker run -d --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n n8nio/n8n

# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Download Llama2 model
ollama pull llama2

# Verify
docker ps
ollama list
```

Then access n8n at: `http://YOUR_VM_IP:5678`

## Lab Structure

| Time | Activity |
|------|----------|
| 5 min | Environment setup + test files |
| 3 min | n8n UI tour |
| 20 min | Build workflow (8 steps) |
| 12 min | Test scenarios + watch cleanup |
| 5 min | Discussion + Q&A |

## Files in This Lab

```
02-n8n-byo-lab/
├── README.md (you are here)
├── lab-guide.md                    # Detailed step-by-step instructions
├── setup-lab-vm.sh                 # Full VM setup script
├── sample-data/
│   ├── test-scenarios.sh           # Create disk space test conditions
│   ├── ollama-test.sh              # Verify Ollama is working
│   └── disk-usage-examples.txt     # Sample du/df outputs
├── reference/
│   ├── linux-commands-cheatsheet.md    # df, du, find reference
│   ├── n8n-nodes-reference.md          # Quick reference for nodes
│   ├── ollama-prompts.md               # Example AI prompts
│   └── workflow-architecture.md        # Workflow diagram
├── solutions/
│   └── disk-cleanup-workflow.json      # Complete workflow
└── extensions/
    └── advanced-challenges.md          # Optional enhancements
```

## Safety First

This lab operates on **test files in /tmp only**.

⚠️ **Paths to NEVER auto-delete:**
- `/home` - User data
- `/etc` - System configuration
- `/var/lib` - Application data
- `/opt` - Installed applications
- `/root` - Root user files

✅ **Safe for testing:**
- `/tmp` - Temporary files (used in this lab)
- `/var/tmp` - Temp files with longer retention
- `/var/log` - Logs (with caution)
- `/var/cache` - Cache files

## Next Steps

1. **Start Here:** [lab-guide.md](lab-guide.md) - Complete step-by-step instructions
2. **Test Setup:** Run `sample-data/ollama-test.sh` to verify your environment
3. **Build Workflow:** Follow the lab guide to create your automation
4. **Test It:** Use `sample-data/test-scenarios.sh` to create test conditions

## Translating to Azure

This pattern directly applies to:
- **Azure VMs:** Monitor C: drive or /var disk usage
- **App Service:** Log cleanup for web apps
- **Container Registry:** Old image cleanup
- **Storage Accounts:** Lifecycle management automation
- **AKS:** Persistent volume monitoring

Same workflow pattern, just different targets!

## Help & Support

- **Stuck?** Check [reference/troubleshooting.md](reference/)
- **Want more?** See [extensions/advanced-challenges.md](extensions/advanced-challenges.md)
- **Questions?** Ask your instructor during lab time

## Credits

This lab is part of the **Whey-AI-Man** project - increasing AI literacy and accessibility through hands-on education.

---

Ready to build? Head to [lab-guide.md](lab-guide.md) to begin!
