# AI Guardrails and Architectural Principles

A governance framework for safe, compliant, and sovereign AI adoption on large-scale shared platforms. Written for architects, engineers, information governance, and security teams responsible for introducing AI and LLM-based capabilities into regulated environments.

## Contents

| File | Description |
|------|-------------|
| `AI-Guardrails-and-Principles.md` | Full governance paper — principles, deployment models, scope, and assurance process |
| `AI-Guardrails-and-Principles.pptx` | Presentation deck based on the paper |

## The 9 Foundational Principles

| ID | Principle |
|----|-----------|
| AI-01 | Data Protection and Sovereignty First |
| AI-02 | Use the Least-Privilege Model Approach |
| AI-03 | Default to RAG and Frozen Model |
| AI-04 | Avoid Fine-Tuning |
| AI-05 | Enforce Organisational Boundaries |
| AI-06 | Prefer MaaS for Low-Risk, Self-Hosted for Sensitive |
| AI-07 | Principled Selection of Open vs Closed Models |
| AI-08 | Inference Pipeline Guardrails |
| AI-09 | Designing for Vendor-Neutral AI Architectures |

## Scope

This framework covers two AI deployment models:

- **Model-as-a-Service (MaaS)** — consuming LLMs via managed enterprise cloud APIs (e.g. Azure OpenAI). Suitable for low-risk, non-sensitive workloads with contractual sovereignty and no-training guarantees.
- **Self-Hosted** — deploying models within controlled infrastructure. Required for sensitive, regulated, or patient-adjacent data.

Out of scope: consumer AI tools, SaaS-embedded AI (e.g. M365 Copilot), RAG patterns, fine-tuning strategies, and vector store selection.

## Assurance

All AI solutions must pass formal review before delivery. Proposals should be raised as a Decision work item and presented to senior architecture, security, clinical safety, and service management representatives. No AI solution may proceed without formal approval.

## Author

Dean Lawrence — `dean.lawrence@avanade.com`
Version 1.0 — February 2026
