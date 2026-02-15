# Disk Space Cleanup Lab - Participant Guide

## Welcome to the Intelligent Disk Space Cleanup Lab! 🎓

**Duration:** 45 minutes
**What you'll build:** An AI-powered automation that monitors disk space and automatically cleans up files

---

## Before You Start

### Prerequisites
- ✅ Azure account (free tier works)
- ✅ Web browser (Chrome, Firefox, or Edge)
- ✅ Basic Linux command knowledge helpful but not required

### What You'll Learn
- Build automation workflows with n8n
- Integrate AI (Ollama/Llama2) for intelligent decisions
- Apply monitor → detect → analyze → remediate pattern
- Translate to Azure infrastructure automation

---

## Lab Setup Instructions

### Step 1: Open Azure Cloud Shell
1. Go to **[portal.azure.com](https://portal.azure.com)**
2. Sign in with your Azure account
3. Click the **Cloud Shell** icon (>_) in the top menu
4. Select **Bash** when prompted
5. Wait for initialization (~30 seconds)

### Step 2: Clone the Lab Repository
Copy and paste this command:

```bash
git clone https://github.com/deanl1982/Whey-AI-Man.git
cd Whey-AI-Man/02-n8n-byo-lab
ls -la
```

### Step 3: Configure Your Lab Environment
```bash
# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Open the editor
code terraform.tfvars
```

**Update these values:**
```hcl
admin_password = "YourSecurePassword123!"  # ⚠️ CHANGE THIS!
vm_count = 1                                # Keep as 1 for your personal VM
resource_group_name = "rg-YOUR-NAME-lab"   # Make it unique with your name
```

💾 **Save:** Press `Ctrl+S`
❌ **Close editor:** Press `Ctrl+Q`

### Step 4: Deploy Your Lab VM
```bash
# Initialize Terraform
terraform init

# Preview what will be created
terraform plan

# Deploy (takes ~5 minutes)
terraform apply
```

⚠️ Type **`yes`** when prompted and press Enter

⏱️ **Wait for deployment to complete...**

### Step 5: Get Your VM Details
```bash
terraform output vm_info
```

**You'll see something like:**
```
vm_info = {
  "lab-vm-1" = {
    "n8n_url"  = "http://20.90.123.45:5678"
    "public_ip" = "20.90.123.45"
    "ssh"      = "ssh adminuser@20.90.123.45"
  }
}
```

📋 **Copy your VM IP address and n8n URL - you'll need these!**

### Step 6: Connect to Your VM
```bash
# Use the SSH command from the output above
ssh adminuser@YOUR_VM_IP

# Enter the password you set in terraform.tfvars
```

### Step 7: Setup n8n and Ollama
Once connected to your VM:

```bash
# Clone the repo on the VM
git clone https://github.com/deanl1982/Whey-AI-Man.git
cd Whey-AI-Man/02-n8n-byo-lab

# Make script executable
chmod +x setup-lab-vm.sh

# Run setup
./setup-lab-vm.sh
```

⏱️ **This takes ~15 minutes. It will:**
- Install Docker
- Setup n8n
- Install Ollama
- Download Llama2 model (~4GB)

☕ **Grab a coffee while it downloads!**

### Step 8: Verify Everything Works
```bash
# Check Docker
docker ps

# Check Ollama
ollama list

# Run verification test
./sample-data/ollama-test.sh
```

✅ All tests should pass!

### Step 9: Access n8n
Open your web browser to: **`http://YOUR_VM_IP:5678`**

🎉 **You're ready to start the lab!**

---

## During the Lab

### Follow Along
Open the detailed lab guide:
- **In your VM:** `cd ~/Whey-AI-Man/02-n8n-byo-lab`
- **Read:** `cat lab-guide.md` or view on GitHub

### Build Your Workflow
You'll create an 8-step workflow that:
1. Monitors disk space every 60 seconds
2. Detects when usage > 85%
3. Analyzes what's using space
4. Asks AI (Llama2) what to clean
5. Executes cleanup commands
6. Verifies space was freed
7. Sends notification

### Test Scenarios
Create test files to trigger cleanup:

```bash
# Create large log files
./sample-data/test-scenarios.sh logs

# Check disk usage
./sample-data/test-scenarios.sh status

# Clean up test files
./sample-data/test-scenarios.sh reset
```

---

## After the Lab

### Save Your Work
Export your n8n workflow:
1. In n8n, click the "..." menu
2. Select "Download"
3. Save the JSON file

### Cleanup (Important!)
**To avoid Azure charges, destroy your resources:**

```bash
# Exit SSH (back to Cloud Shell)
exit

# Navigate to lab directory
cd ~/Whey-AI-Man/02-n8n-byo-lab

# Destroy everything
terraform destroy
```

⚠️ Type **`yes`** when prompted

This removes all VMs and infrastructure.

---

## Quick Reference

### Your Lab Details
Fill these in during setup:

```
╔═══════════════════════════════════════════════╗
║  My Lab Environment                           ║
╠═══════════════════════════════════════════════╣
║  VM IP:    ______________________________     ║
║  n8n URL:  http://____________:5678           ║
║  Password: ______________________________     ║
╚═══════════════════════════════════════════════╝
```

### Useful Commands

**Check what's running:**
```bash
docker ps                    # See n8n container
ollama list                  # See AI models
```

**Restart services:**
```bash
docker restart n8n           # Restart n8n
sudo systemctl restart ollama # Restart Ollama
```

**Check disk space:**
```bash
df -h /tmp                   # Disk usage
du -sh /tmp/*                # What's using space
```

---

## Help & Support

### During the Lab
- 🙋 Ask your instructor
- 📖 Check [lab-guide.md](lab-guide.md)
- 📚 See [reference/](reference/) folder for cheat sheets

### Troubleshooting

**Can't access n8n?**
- Check VM is running: `az vm list -g rg-YOUR-NAME-lab`
- Verify n8n container: `docker ps`
- Restart if needed: `docker restart n8n`

**Ollama not working?**
- Check service: `ps aux | grep ollama`
- Run test: `./sample-data/ollama-test.sh`
- View logs: `journalctl -u ollama -f`

**SSH issues?**
- Verify IP: `terraform output vm_info`
- Check password: Use what you set in terraform.tfvars
- Wait a few minutes for VM to fully start

---

## What's Next?

### Learn More
- Explore [extensions/advanced-challenges.md](extensions/advanced-challenges.md)
- Try different scenarios with test-scenarios.sh
- Adapt the workflow for your own infrastructure

### Apply to Your Work
This pattern works for:
- Azure VM disk monitoring
- Log rotation automation
- Container cleanup
- Storage account lifecycle management
- Database backup cleanup

### Share Your Experience
- Export and share your workflow
- Discuss with colleagues
- Deploy to production (with safety measures!)

---

## Cost Information

**This lab costs approximately:**
- Lab session (45 mins): ~£0.14 per VM
- Extended learning (4 hours): ~£0.70 per VM

**Remember to run `terraform destroy` when finished!**

---

## Questions?

**During lab:** Ask your instructor
**After lab:** Review documentation in the repo
**GitHub:** https://github.com/deanl1982/Whey-AI-Man

---

**Good luck and enjoy the lab! 🚀**
