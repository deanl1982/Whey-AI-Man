## Table of Contents

[[_TOC_]]

## Document Control

### Document Information

| Field | Value |
| ----: | ----- |
| Title | `AI Use Case Value Assessment Template` |
| Author(s) | `xxxxx@nhs.net` |
| Version | `0.1` |
| Date | `19.10.2025` |

### Document Revision History

| Version | Date       | Changed By  | Change          |
| ------: | ----:      | ----------: | ------:         |
| `0.1`     | `19.10.2025` | `dean.lawrence4@nhs.net`    | `Initial version` |

---

## Opening Note: AI Governance Alignment
Before completing this template, the Product Owner must confirm they have reviewed the organisation’s **AI Governance Principles**, including Responsible AI guidance and architectural guardrails.

All responses in this document should reflect those principles — particularly around:
- Safety & reliability  
- Accountability  
- Transparency  
- Data privacy & security  
- Fairness & inclusiveness  
- Human oversight  

---

## 1. Project Name & Summary
*A short description that captures the essence of the idea in one or two sentences.*

**Example:** “Agent to triage inbound customer queries and route to relevant teams.”

**Project Summary:**  
-

---

## 2. Problem Statement
**Purpose:** Ensure the team has a clear, measurable understanding of the problem before considering any AI solution.

**Guidance:**
- Describe the specific problem you want to solve.
- Explain *who* experiences the problem and *how* it impacts them.
- Quantify the problem where possible (time lost, error rates, user frustration, cost impact).
- Ensure this is understandable to business, operations, and security stakeholders.
- If you can’t explain the problem simply, it’s not yet understood well enough.

**Fields:**
- **Problem description:**  
- **Who is impacted:**  
- **Measurable indicators (KPIs affected):**  
- **Root causes (if known):**  

---

## 3. Desired Outcomes & Success Measures
**Purpose:** Define what “good looks like” before designing the solution.

**Guidance:**
- What outcomes should the agent deliver?
- What metrics would show improvement?
- What behaviour or capabilities must the agent demonstrate?
- Focus on business value over technical metrics.

**Fields:**
- **Target outcomes / value delivered:**  
- **Success metrics:**  
- **Time horizon for seeing value:**  

---

## 4. Impact vs Effort Assessment
**Purpose:** Assess expected value vs complexity using the Impact/Effort matrix.

**Guidance:**
- Rate business impact (High / Medium / Low).
- Rate delivery effort (High / Medium / Low).
- Position on the matrix:
  - **Quick Win** (High Impact / Low Effort)
  - **Strategic Bet** (High Impact / High Effort)
  - **Avoid** (Low Impact / High Effort)
- Provide rationale.

**Fields:**
- **Impact rating:**  
- **Effort rating:**  
- **Matrix position:**  
- **Justification:**  

---

## 5. Proposed AI Agent Concept
**Purpose:** Encourage creative thinking — this is not a design.

**Guidance:**
- Describe the type of agent imagined (e.g., advisor, automation agent, retrieval assistant).
- Outline the tasks it performs.
- Describe how users interact with it.

**Fields:**
- **Agent type envisioned:**  
- **High-level behaviours / capabilities:**  
- **User interaction model:**  

---

## 6. Model & Deployment Preference (Initial Thinking)
**Purpose:** Capture early thinking on how the agent might be deployed, aligned to AI governance guardrails.

**Guidance:**
Consider:
- Will this use **Model-as-a-Service (MaaS)** or **Self-Hosted** models?
- Will the model be **closed-source** (e.g., Azure OpenAI, Anthropic) or **open-source** (e.g., Llama, Mistral)?
- Does the choice align with:
  - data handling constraints  
  - safety requirements  
  - privacy  
  - sovereignty  
  - performance expectations  

*(This is not binding — the architecture team will perform a full review later.)*

**Fields:**
- **Deployment preference (MaaS / Self-Hosted):**  
- **Model type preference (Closed / Open):**  
- **Reasoning and governance alignment:**  

---

## 7. Required Tools, Integrations & Data Sources
**Purpose:** Begin considering feasibility without creating a design.

**Guidance:**
- What tools or APIs might the agent need?
- Which systems might require integration?
- What data sources might support Retrieval-Augmented Generation (RAG)?
- Any early privacy or security considerations?

**Fields:**
- **Potential tools required:**  
- **Potential system integrations:**  
- **Possible RAG data sources:**  
- **Security / privacy considerations:**  

---

## 8. Stakeholder Involvement
**Purpose:** Ensure cross-functional alignment early.

**Guidance:**
Identify all key stakeholders:
- Business owner(s)
- Product team(s)
- Data owners
- Security / Risk
- Operations
- End-users

**Fields:**
- **Primary business sponsor:**  
- **Stakeholders consulted:**  
- **Stakeholders who must validate assumptions:**  

---

## 9. Testing Strategy & Model Evaluation (Initial Concept)
**Purpose:** Understand early thinking on how you will validate the agent’s behaviour.

**Guidance:**
Teams should outline:
- How they plan to test the agent (functional, safety, hallucination testing, UX tests, edge cases).
- What test data will be used (synthetic, anonymised, curated examples).
- How they propose to evaluate and control the **probabilistic nature** of the model:
  - guardrails  
  - deterministic modes    
  - content filters  
  - prompt constraints  
  - fallback behaviour  

*(This is exploratory — final testing plans come later.)*

**Fields:**
- **Test approach (how the agent will be tested):**  
- **Test data sources and preparation:**  
- **Managing probabilistic behaviour (controls, guardrails, mitigations):**  

---

## 10. Risks, Dependencies & Constraints
**Purpose:** Surface feasibility issues early.

**Guidance:**
Consider:
- Data availability or quality issues
- Integration complexity
- Licensing / cost constraints
- Ethical or Responsible AI considerations
- Change management impact
- Safety or operational risk
- Reliability / failover needs

**Fields:**
- **Known risks or concerns:**  
- **Dependencies:**  
- **Constraints / blockers:**  

---

## 11. Recommendation & Next Steps
**Purpose:** Give leadership a clear decision path.

**Guidance:**
- State whether the idea should progress to discovery/design.
- Outline the first step (prototype, feasibility assessment, data exploration).
- If not recommended, explain why.

**Fields:**
- **Team’s recommendation:**  
- **Justification:**  
- **Suggested next steps if approved:**  

---
