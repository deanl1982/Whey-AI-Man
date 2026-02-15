# Whey-AI-Man

**Making AI literacy accessible through hands-on education and practical automation labs.**

---

## 🎯 Mission

Whey-AI-Man demystifies AI by providing clear, practical education and hands-on labs that help people understand how AI works and apply it to real-world infrastructure automation scenarios.

---

## 📚 Project Contents

### 01-build-n8n/
**n8n Infrastructure Setup for Azure**

Complete infrastructure-as-code setup for deploying n8n automation platform on Azure VMs.

**Contents:**
- Terraform configuration for Azure VM
- n8n container setup scripts
- nginx web server configuration
- AI agent system prompts and examples

**Use Case:** Foundation for building AI-powered automation workflows on Azure.

**Status:** ✅ Production-ready

---

### 02-n8n-byo-lab/ ⭐ **New!**
**Intelligent Disk Space Cleanup Lab**

A complete 45-minute hands-on lab teaching infrastructure automation with n8n and AI.

**What You'll Build:**
An AI-powered workflow that:
- 🔍 Monitors disk space usage automatically
- 🤖 Uses LLM (Llama2) to analyze what's consuming space
- 🧹 Intelligently cleans up old files
- ✅ Verifies and reports results

**Perfect For:**
- Azure Infrastructure SMEs
- DevOps engineers
- System administrators
- Anyone interested in AI-powered automation

**Learning Outcomes:**
- n8n workflow automation fundamentals
- Integrating Ollama/Llama2 for intelligent decisions
- Prompt engineering for DevOps tasks
- Monitor → Detect → Analyze → Remediate patterns
- Translating to Azure infrastructure scenarios

**What's Included:**
```
02-n8n-byo-lab/
├── README.md                  # Lab overview & quick start
├── DEPLOYMENT.md              # Detailed deployment guide
├── PARTICIPANT-HANDOUT.md     # Printable participant guide
├── lab-guide.md               # Step-by-step lab instructions
├── n8n-vm.tf                  # Terraform for Azure VMs
├── setup-lab-vm.sh            # Automated VM setup script
├── sample-data/               # Test scenarios & verification
├── reference/                 # Command cheatsheets & docs
├── solutions/                 # Complete workflow export
└── extensions/                # 11 advanced challenges
```

**Quick Start:**
```bash
# Clone the repo
git clone https://github.com/deanl1982/Whey-AI-Man.git
cd Whey-AI-Man/02-n8n-byo-lab

# Follow README for Azure Cloud Shell deployment
```

**Duration:** 45 minutes
**Cost:** ~£0.14 per participant (Azure Standard_D4s_v3 VM)
**Prerequisites:** Azure account, web browser

**Status:** ✅ Ready for lab sessions

---

## 🚀 Getting Started

### For Lab Instructors
1. **Review the lab:** [02-n8n-byo-lab/README.md](02-n8n-byo-lab/README.md)
2. **Deploy infrastructure:** Use Azure Cloud Shell + Terraform
3. **Share participant guide:** [PARTICIPANT-HANDOUT.md](02-n8n-byo-lab/PARTICIPANT-HANDOUT.md)
4. **Run the lab:** Follow [lab-guide.md](02-n8n-byo-lab/lab-guide.md)

### For Participants
1. **Prerequisites:** Azure account + web browser
2. **Clone repo:** `git clone https://github.com/deanl1982/Whey-AI-Man.git`
3. **Follow guide:** [PARTICIPANT-HANDOUT.md](02-n8n-byo-lab/PARTICIPANT-HANDOUT.md)
4. **Build automation:** Guided step-by-step

### For Infrastructure Teams
1. **Explore base setup:** [01-build-n8n/](01-build-n8n/)
2. **Deploy n8n platform:** Use Terraform configs
3. **Build custom workflows:** Adapt lab patterns to your needs

---

## 🎓 Learning Path

### Beginner
Start with the **Disk Space Cleanup Lab** ([02-n8n-byo-lab/](02-n8n-byo-lab/)):
- No coding required
- Visual workflow builder
- Guided instructions
- Immediate practical value

### Intermediate
After completing the basic lab, try:
- Advanced challenges ([extensions/advanced-challenges.md](02-n8n-byo-lab/extensions/advanced-challenges.md))
- Multi-tier cleanup strategies
- Azure Monitor integration
- Multi-server monitoring

### Advanced
Build production automation:
- Adapt patterns to your infrastructure
- Implement safety validations
- Add human approval workflows
- Create custom AI agents

---

## 🏗️ Architecture

### Technology Stack
- **Automation:** n8n (workflow automation platform)
- **AI/LLM:** Ollama + Llama2 (local, free)
- **Infrastructure:** Azure VMs (Terraform IaC)
- **Container:** Docker
- **OS:** Ubuntu 20.04 LTS

### Deployment Model
- **Development:** Single VM for testing
- **Lab Session:** One VM per participant
- **Production:** Scalable multi-VM setup

---

## 💡 Use Cases

The patterns taught in these labs apply to:

### Infrastructure Automation
- Disk space management and cleanup
- Log rotation and archiving
- Container image cleanup
- Backup lifecycle management

### Azure-Specific Scenarios
- Azure VM disk monitoring
- App Service log cleanup
- Container Registry maintenance
- Storage Account lifecycle policies
- AKS persistent volume management

### AI-Powered Operations
- Intelligent log analysis
- Anomaly detection
- Predictive maintenance
- Auto-remediation workflows

---

## 📊 Lab Session Details

### Disk Space Cleanup Lab
- **Duration:** 45 minutes
- **Difficulty:** Beginner
- **VM Size:** Standard_D4s_v3 (4 vCPU, 16GB RAM)
- **Cost per participant:** ~£0.14 (45 minutes)
- **Capacity:** Scales to any number of participants
- **Deployment method:** Azure Cloud Shell + Terraform

---

## 🤝 Contributing

We welcome contributions! Ways to contribute:

### Lab Content
- Additional automation scenarios
- Advanced challenge solutions
- Troubleshooting guides
- Real-world examples

### Documentation
- Clarifications and improvements
- Translation to other languages
- Video walkthroughs
- Blog posts and case studies

### Code
- Infrastructure improvements
- New Terraform modules
- Setup script enhancements
- Workflow templates

**How to contribute:**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📁 Repository Structure

```
Whey-AI-Man/
├── README.md (you are here)
├── 01-build-n8n/                   # n8n platform setup
│   ├── n8n-vm.tf                   # Terraform for Azure
│   ├── setup-vm.sh                 # Installation script
│   ├── ai-agent-files/             # Agent prompts
│   └── README.md                   # Documentation
│
└── 02-n8n-byo-lab/                 # Disk Cleanup Lab
    ├── README.md                   # Lab overview
    ├── DEPLOYMENT.md               # Deployment guide
    ├── PARTICIPANT-HANDOUT.md      # Participant guide
    ├── lab-guide.md                # Detailed instructions
    ├── n8n-vm.tf                   # Lab infrastructure
    ├── setup-lab-vm.sh             # Setup automation
    ├── terraform.tfvars.example    # Config template
    ├── sample-data/                # Test scenarios
    ├── reference/                  # Documentation
    ├── solutions/                  # Complete workflows
    └── extensions/                 # Advanced challenges
```

---

## 📖 Documentation

### Quick Links
- **Lab Guide:** [02-n8n-byo-lab/lab-guide.md](02-n8n-byo-lab/lab-guide.md)
- **Deployment:** [02-n8n-byo-lab/DEPLOYMENT.md](02-n8n-byo-lab/DEPLOYMENT.md)
- **Participant Info:** [02-n8n-byo-lab/PARTICIPANT-HANDOUT.md](02-n8n-byo-lab/PARTICIPANT-HANDOUT.md)
- **Reference Docs:** [02-n8n-byo-lab/reference/](02-n8n-byo-lab/reference/)

### Cheat Sheets
- Linux commands (df, du, find)
- n8n nodes reference
- Ollama prompt engineering
- Workflow architecture patterns

---

## 🎯 Learning Objectives

By completing the labs in this repository, you will:

✅ Understand AI-powered automation fundamentals
✅ Build workflows with n8n visual builder
✅ Integrate LLMs (Ollama/Llama2) for intelligent decisions
✅ Write effective prompts for DevOps scenarios
✅ Apply monitor → detect → analyze → remediate patterns
✅ Deploy infrastructure with Terraform
✅ Translate patterns to Azure cloud services
✅ Implement production-ready safety measures

---

## 💬 Community & Support

### During Lab Sessions
- Ask your instructor
- Reference documentation in [reference/](02-n8n-byo-lab/reference/)
- Check troubleshooting guides

### Issues & Questions
- **GitHub Issues:** Report bugs or request features
- **Discussions:** Share experiences and ask questions
- **Pull Requests:** Contribute improvements

---

## 📜 License

This project is open-source and available for educational purposes. Please review the license file for details.

---

## 🙏 Credits

**Whey-AI-Man** is a community-driven project focused on making AI education accessible.

Special thanks to:
- n8n.io for the automation platform
- Ollama for local LLM inference
- Meta for Llama2 model
- Azure community for cloud infrastructure support

---

## 🚀 Next Steps

### Ready to Learn?
1. **Clone the repo:** `git clone https://github.com/deanl1982/Whey-AI-Man.git`
2. **Start with the lab:** `cd 02-n8n-byo-lab`
3. **Read the README:** Follow deployment instructions
4. **Build your first AI-powered automation!**

### Questions?
Open an issue or check the documentation in each directory.

---

**Let's make AI automation accessible to everyone!** 🎓✨
