# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Whey-AI-Man is a Lunch & Learn educational series about AI, LLMs, and automation. It consists of 6 progressive sessions, each in its own numbered directory. This is not a traditional application codebase — it's a collection of infrastructure code, demos, presentations, and datasets designed for hands-on workshop delivery.

## Repository Structure

Sessions are numbered and independent:
- **01-build-n8n/** — Terraform + Bash to deploy n8n on Azure VM (foundation session)
- **02-n8n-byo-lab/** — Enhanced lab with Ollama (local LLM), multi-region SKU checking, multi-participant support
- **03-llm-101/** — LLM fundamentals: Python visualization scripts, interactive bingo game, presentation
- **04-ai-periodic-table/** — Conceptual framework mapping 18 AI concepts
- **05-ai-guardrails/** — AI governance principles for regulated environments
- **06-service-desk-agent/** — Copilot Studio agent demo with synthetic support ticket datasets and facilitation guide

## Key Commands

### Infrastructure (Sessions 01 & 02)
```bash
terraform init
terraform plan
terraform apply
# Session 02 has a SKU checker that auto-selects cheapest Azure region:
./check-sku.sh
```

### Python Demos (Session 03)
```bash
# No requirements.txt — only dependency is matplotlib
python weights-lakes.py
python weights-csotm-before-after.py
```

## Architecture

### Session 02 Stack (most complex)
Browser → n8n (port 5678) → Ollama/llama3.2 (port 11434) → nginx (port 80), all on a single Azure VM (Standard_D4s_v3). Terraform provisions the VM; `setup-lab-vm.sh` installs Docker, n8n, nginx, and Ollama. The `vm_count` variable allows deploying multiple VMs for group labs.

### Session 06 Design
Uses synthetic M365 support ticket CSVs (200 and 500 rows) with four intentionally hidden trends that participants discover through guided prompts. The `system-prompt.txt` defines a Service Management Intelligence Analyst persona for Copilot Studio.

## Cloud Platform

All infrastructure targets **Azure** using the `azurerm` Terraform provider. VM setup scripts assume Ubuntu/Debian.
