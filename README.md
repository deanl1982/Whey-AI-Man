# Whey-AI-Man

**Making AI literacy accessible through hands-on education, community talks, and practical automation labs.**

---

## Mission

Whey-AI-Man is a Lunch & Learn series that demystifies AI — from the fundamentals of how Large Language Models work, to building your own AI agents with real infrastructure. Each session is designed to be approachable, practical, and hands-on.

---

## Sessions

| # | Session | Description |
|---|---------|-------------|
| 01 | [Build n8n](01-build-n8n/) | n8n automation platform infrastructure setup on Azure |
| 02 | [BYO AI Agent Lab](02-n8n-byo-lab/) | Hands-on lab — deploy your own n8n + Ollama AI agent |
| 03 | [LLM 101](03-llm-101/) | Understanding Large Language Models — history, transformers, and how they learn |
| 04 | [AI Periodic Table](04-ai-periodic-table/) | A framework for organising AI terminology into a periodic table |
| 05 | [AI Guardrails](05-ai-guardrails/) | Governance framework for safe, compliant, and sovereign AI adoption |
| 06 | [Service Desk Agent](06-service-desk-agent/) | Build a Copilot Studio agent that analyses service desk data to identify hidden trends |

---

## Repository Structure

```
Whey-AI-Man/
├── README.md
│
├── 01-build-n8n/                          # n8n platform setup
│   ├── n8n-vm.tf                          # Terraform for Azure VM
│   ├── setup-vm.sh                        # Installation script
│   ├── set-nginx-home.sh                  # Custom nginx homepage
│   ├── ai-agent-files/                    # Agent system prompts
│   └── README.md
│
├── 02-n8n-byo-lab/                        # Build Your Own AI Agent Lab
│   ├── n8n-vm.tf                          # Lab Terraform config
│   ├── setup-lab-vm.sh                    # Automated VM setup
│   ├── check-sku.sh                       # Azure SKU availability check
│   ├── terraform.tfvars.example           # Config template
│   ├── n8n-files/                         # Ready-to-import workflows
│   │   ├── SSH-Tools.json                 # SSH sub-workflow
│   │   └── Web-Server-Health-Agent-Ollama.json
│   └── README.md
│
├── 03-llm-101/                            # LLM 101 talk materials
│   ├── llm101.pptx                        # Presentation slides
│   ├── bingo.html                         # Interactive AI bingo game
│   ├── weights-lakes.py                   # Neural network weight demos
│   ├── weights-csotm-before-after.py      # Before/after weight comparison
│   ├── whey-ai-man-banner-middle.png      # Banner graphic
│   └── README.md
│
├── 04-ai-periodic-table/                  # AI Periodic Table talk
│   ├── _AI-Periodic-Table.pptx            # Slide deck
│   └── README.md
│
├── 05-ai-guardrails/                      # AI Guardrails and Principles
│   ├── AI-Guardrails-and-Principles.pptx  # Presentation deck
│   └── README.md
│
└── 06-service-desk-agent/                 # Service Desk Trend Analysis Agent
    ├── m365_support_tickets_200.csv       # 200-ticket dataset
    ├── m365_support_tickets_500.csv       # 500-ticket dataset
    ├── system-prompt.txt                  # Agent system prompt
    ├── guided-prompts.md                  # Progressive demo prompt sequence
    └── README.md
```

---

## Session Details

### 01 — Build n8n

**n8n Infrastructure Setup for Azure**

Complete infrastructure-as-code setup for deploying the n8n automation platform on an Azure VM. This is the foundation used by the BYO Lab session.

- Terraform configuration for Azure VM provisioning
- n8n container setup via Docker
- nginx web server with custom homepage
- AI agent system prompts for web server monitoring

---

### 02 — BYO AI Agent Lab

**Build Your Own n8n + AI Agent Lab** | 45 minutes

Deploy your own n8n instance paired with a free local LLM (Ollama + llama3.2). Build, test, and iterate on AI agents — no paid API keys required.

**What you'll build:** An AI agent that monitors an nginx web server, detects failures, analyses logs using a local LLM, auto-remediates issues, and reports results via a chat interface.

**What you'll get:**
- n8n automation platform running in Docker
- Local Ollama instance with llama3.2 (free)
- Pre-built example workflows to learn from and extend
- SSH tooling for system-level automation
- A chat interface to interact with your AI agents

**Perfect for:** Azure Infrastructure SMEs, DevOps engineers, system administrators, and anyone curious about AI agents.

---

### 03 — LLM 101

**Understanding Large Language Models**

A technical introduction to how LLMs actually work — from the history of AI through to the transformer architecture powering ChatGPT, Claude, and Gemini.

**Topics covered:**
- History of AI and machine learning
- Neural networks — weights, training, backpropagation
- The transformer architecture
- Tokenization and embeddings
- Prompt engineering fundamentals
- LLM limitations and challenges

**Includes:** Presentation slides, interactive AI bingo game, and Python demos for neural network weight calculations.

---

### 04 — AI Periodic Table

**A Framework for Organising AI Terminology**

Inspired by chemistry's periodic table, this session maps 18 AI concepts into a grid where position predicts behaviour — from Prompts and Embeddings at the primitive level, through RAG and Agents, to emerging concepts like Multi-Agent systems and Synthetic Data.

**The table predicts how concepts combine:**
- **Production RAG:** Embeddings → Vector DB → RAG → Prompts → LLM + Guardrails
- **Agentic Loop:** Agents ↔ Function Calling deployed in Frameworks

**Includes:** Slide deck and speaker notes.

---

### 05 — AI Guardrails

**Governance Framework for Safe, Compliant, and Sovereign AI Adoption**

A set of 9 foundational principles for introducing AI and LLM-based capabilities into regulated environments. Written for architects, engineers, information governance, and security teams working on large-scale shared platforms.

**Covers two deployment models:**
- **Model-as-a-Service (MaaS)** — consuming LLMs via managed enterprise cloud APIs (e.g. Azure OpenAI)
- **Self-Hosted** — deploying models within controlled infrastructure for sensitive or regulated data

**Key principles include:** Data sovereignty, least-privilege models, RAG-first architecture, organisational boundaries, inference pipeline guardrails, and vendor-neutral AI design.

**Includes:** Full governance paper and presentation deck.

---

### 06 — Service Desk Agent

**Service Desk Trend Analysis with Copilot Studio**

Build a Copilot Studio agent that analyses M365 service desk data to identify trends and patterns that would typically require hours of manual investigation. The agent surfaces underlying problems hidden across hundreds of individual incident tickets.

**What you'll build:** A declarative agent in Copilot Studio that ingests simulated ServiceNow incident data and identifies cross-ticket correlations humans would miss.

**What the agent finds:**
- Outlook crashes linked to a specific Windows update (KB5041585)
- OneDrive sync failures isolated to a single network segment (VLAN-230)
- Teams call quality degradation routed through a specific proxy (PROXY-UK-02)
- SharePoint permission errors following a tenant migration (Project Atlas)

**Demonstrates:** The value of AI in problem management — shifting from reactive incident handling to proactive trend identification.

**Includes:** Two datasets (200 and 500 tickets), system prompt, guided demo prompts, and a facilitator answer key.

## Contributing

Fork, open an issue, or submit a PR. If you add a session, include a README and any supporting materials.


## License

This project is open-source and available for educational purposes. Please review the license file for details.



### Questions?
Open an issue or check the documentation in each directory.

---

**Let's make AI agent development accessible to everyone!**
