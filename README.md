# Whey-AI-Man

**Making AI literacy accessible through hands-on education and practical automation labs.**

---

## Mission

Whey-AI-Man demystifies AI by providing clear, practical education and hands-on labs that help people understand how AI works and apply it to real-world infrastructure automation scenarios.

---

## Repository Structure

```
Whey-AI-Man/
├── README.md (you are here)
├── 01-build-n8n/                          # n8n platform setup
│   ├── n8n-vm.tf                          # Terraform for Azure
│   ├── setup-vm.sh                        # Installation script
│   ├── set-nginx-home.sh                  # Custom nginx homepage
│   ├── ai-agent-files/                    # Agent prompts
│   └── README.md                          # Documentation
│
└── 02-n8n-byo-lab/                        # Build Your Own AI Agent Lab
    ├── README.md                          # Lab guide & setup
    ├── n8n-vm.tf                          # Lab infrastructure
    ├── setup-lab-vm.sh                    # Setup automation
    ├── terraform.tfvars.example           # Config template
    └── n8n-files/                         # Example workflows
        ├── SSH-Tools.json                 # SSH sub-workflow
        └── Web-Server-Health-Agent-Ollama.json  # Example AI agent
```

---

## Project Contents

### 01-build-n8n
**n8n Infrastructure Setup for Azure**

Complete infrastructure-as-code setup for deploying n8n automation platform on Azure VMs.

**Contents:**
- Terraform configuration for Azure VM
- n8n container setup scripts
- nginx web server configuration
- AI agent system prompts and examples

**Use Case:** Foundation for building AI-powered automation workflows on Azure.

---

### 02-n8n-byo-lab
**Build Your Own n8n + AI Agent Lab**

A hands-on 45-minute lab where you deploy your own n8n instance paired with a free local LLM (Ollama + llama3.2). The goal is to give you a personal AI agent development environment so you can learn to build, test, and iterate on AI agents — no paid API keys required.

**What You'll Get:**
- Your own n8n automation platform running in Docker
- A local Ollama instance with llama3.2 (completely free)
- Pre-built example workflows to learn from and extend
- SSH tooling for system-level automation
- A chat-based interface to interact with your AI agents

**Why This Lab Exists:**
AI agent development is a powerful skill, but getting started can be expensive and complex. This lab removes those barriers by giving you a fully working environment in under an hour — using free, open-source tools running locally on an Azure VM.

**Perfect For:**
- Azure Infrastructure SMEs
- DevOps engineers
- System administrators
- Anyone interested in building AI agents

**What's Included:**
```
02-n8n-byo-lab/
├── README.md                              # Complete lab guide & setup
├── n8n-vm.tf                              # Terraform for Azure VMs
├── setup-lab-vm.sh                        # Automated VM setup script
├── terraform.tfvars.example               # Configuration template
└── n8n-files/                             # Ready-to-import workflows
    ├── SSH-Tools.json                     # SSH command execution
    └── Web-Server-Health-Agent-Ollama.json  # Example AI monitoring agent
```

## Architecture

### Technology Stack
- **Automation:** n8n (workflow automation platform)
- **AI/LLM:** Ollama + llama3.2 (local, free)
- **Infrastructure:** Azure VMs (Terraform IaC)
- **Container:** Docker
- **OS:** Ubuntu 20.04 LTS

### Deployment Model
- **Development:** Single VM for testing
- **Lab Session:** One VM per participant
- **Production:** Scalable multi-VM setup

## Lab Session Details

### Build Your Own n8n + AI Agent Lab
- **Duration:** 45 minutes
- **Difficulty:** Beginner
- **VM Size:** Standard_D4s_v3 (4 vCPU, 16GB RAM)
- **Cost per participant:** ~£0.14 (45 minutes)
- **Capacity:** Scales to any number of participants
- **Deployment method:** Azure Cloud Shell + Terraform

## Learning Objectives

By completing the labs in this repository, you will:

- Understand AI-powered automation fundamentals
- Deploy your own n8n instance with a local LLM
- Build AI agents using n8n's visual workflow builder
- Integrate Ollama (llama3.2) for intelligent decision-making
- Write effective prompts for DevOps and infrastructure scenarios
- Apply monitor, detect, analyze, remediate patterns
- Deploy infrastructure with Terraform
- Develop the skills to build your own AI agents for any use case

---

## Contributing

We welcome contributions! Ways to contribute:

### Lab Content
- Additional automation scenarios
- New AI agent examples
- Troubleshooting guides
- Real-world use cases

### Documentation
- Clarifications and improvements
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

## License

This project is open-source and available for educational purposes. Please review the license file for details.

---

## Credits

**Whey-AI-Man** is a community-driven project focused on making AI education accessible.

Special thanks to:
- n8n.io for the automation platform
- Ollama for local LLM inference
- Meta for the Llama model family
- Azure community for cloud infrastructure support

---

## Next Steps

### Ready to Learn?
1. **Clone the repo:** `git clone https://github.com/deanl1982/Whey-AI-Man.git`
2. **Start with the lab:** `cd 02-n8n-byo-lab`
3. **Read the README:** Follow deployment instructions
4. **Build your first AI agent!**

### Questions?
Open an issue or check the documentation in each directory.

---

**Let's make AI agent development accessible to everyone!**
