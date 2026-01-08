## n8n Lab Environment

This repository contains infrastructure as code (IaC) and setup scripts for deploying n8n in an Azure environment. n8n is a workflow automation tool that allows you to connect different services and automate tasks.

## Project Structure

```plaintext
├── 01-Build-N8N/
│   ├── n8n-vm.tf       # Terraform configuration for Azure infrastructure
│   └── setup-vm.sh     # Shell script for installing and configuring n8n and dependencies
```

# Whey-AI-Man

Summary
-------

Whey-AI-Man is a small repository that combines infrastructure-as-code and lightweight AI/automation prototypes. The repo provides scripts and Terraform to provision an n8n automation VM, plus a folder of example AI apps and sample data for local experimentation.

Why this repo exists:
- Provision a reproducible n8n workflow automation environment
- Host and iterate on simple AI-powered apps and example prompts/data

Repository layout
-----------------

- [01-build-n8n](01-build-n8n): Terraform and shell scripts to provision and configure an n8n VM (networking, nginx, Docker, n8n setup).
- [02-apps-tda](02-apps-tda): Python prototypes, example prompts, and sample JSON data used by the AI/agent experiments.
- [01-build-n8n/ai-agent-files](01-build-n8n/ai-agent-files): system prompt and supporting files used by the agent automation.

Quickstart (local/high level)
-----------------------------

Prerequisites:
- Terraform
- Azure CLI (for Azure deployments) or appropriate cloud credentials
- Bash shell (or WSL on Windows)
- Python 3.10+ and pip (for the example apps)

Basic steps:
1. Provision infrastructure (optional — skip if you only want to run local examples):

   ```bash
   cd 01-build-n8n
   terraform init
   terraform apply
   ```

2. After the VM is created, connect and run the setup script on the VM (example):

   ```bash
   # on the provisioned VM
   sudo chmod +x setup-vm.sh
   ./setup-vm.sh
   ```

3. Run the example AI app locally:

   ```bash
   cd 02-apps-tda
   python -m venv .venv
   . .venv/bin/activate   # or .venv\\Scripts\\activate on Windows
   pip install -r requirements.txt  # if present
   python apps-tda.py --help
   ```

Files of interest
-----------------
- [01-build-n8n/n8n-vm.tf](01-build-n8n/n8n-vm.tf) — Terraform configuration for the VM.
- [01-build-n8n/setup-vm.sh](01-build-n8n/setup-vm.sh) — VM setup script (Docker, nginx, n8n).

Notes & next steps
------------------
- The repo mixes infra and prototype code; treat the scripts as examples rather than production-ready automation.
- If you plan to deploy the VM, review and update any secrets and network rules before applying Terraform.

Contributing
------------

Fork, open an issue, or submit a PR. If you add features, please include short README notes and any dependency changes (requirements file, etc.).

License
-------

See [LICENSE](LICENSE) if present.

Project status
--------------

This repository is experimental and intended for development, testing, and demos. The infra scripts and example apps are NOT production-ready — review secrets, networking, and hardening before any real deployment.

Security & privacy
------------------

- Do not commit secrets or credentials. Replace any placeholder passwords and keys before applying Terraform.
- Sample data may include synthetic or trimmed data for demos only.

Contact
-------

If you need help or want to propose changes, open an issue or create a pull request on GitHub.
