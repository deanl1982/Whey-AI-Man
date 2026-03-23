# Exercise 01 — Service Desk Trend Analysis Agent

**Whey AI Man — Lunch & Learn Series**

## Overview

In this exercise you'll build a Copilot Studio agent that analyses M365 service desk data to identify trends and patterns that would typically require hours of manual investigation. The goal is to demonstrate AI's ability to surface underlying problems hidden across hundreds of individual incident tickets.

## Artifacts

| File | Purpose |
|------|---------|
| `m365_support_tickets.csv` | 500 simulated ServiceNow incident tickets covering Oct 2025 – Mar 2026 |
| `system-prompt.txt` | System prompt to paste into your Copilot Studio agent configuration |
| `guided-prompts.md` | Progressive prompt sequence to walk the team through the demo |
| `README.md` | This file — facilitator guide and answer key |

## The Dataset

The CSV contains 500 M365 support tickets with the following fields:

- **Ticket ID** — ServiceNow-style INC number
- **Opened / Resolved** — Timestamps
- **Priority** — P1 through P4
- **Status** — Resolved, Closed, or Awaiting Problem Mgmt
- **Category / Subcategory** — M365 service area
- **Short Description** — User-reported symptom
- **Department / Location** — Organisational context
- **Assigned Engineer** — Who worked the ticket
- **Network Segment** — VLAN the user was on
- **Proxy** — Proxy server routing the user's traffic
- **Engineer Comments** — Free-text notes from the engineer
- **Root Cause** — What the engineer recorded as the cause

The data includes realistic noise (genuine, unrelated tickets) alongside **4 hidden trends** that the agent should identify.

## Building the Agent — Step by Step

### 1. Create a new agent in Copilot Studio
- Go to [Copilot Studio](https://copilotstudio.microsoft.com)
- Create a new agent (declarative agent)
- Give it a name, e.g. *"Service Desk Intelligence Analyst"*

### 2. Configure the system prompt
- Open `system-prompt.txt` and paste the contents into the agent's **Instructions** field
- This tells the agent how to behave, what to look for, and how to present findings

### 3. Upload the knowledge source
- Add `m365_support_tickets.csv` as a knowledge source / uploaded file
- The agent will use this as its dataset for analysis

### 4. Test the agent
Try these prompts to see what the agent finds:

**Starter prompt:**
> "Analyse the support ticket data and identify any trends or patterns that suggest underlying problems we should investigate."

**Follow-up prompts:**
> "Are there any patterns related to specific network infrastructure components?"

> "I noticed a lot of Outlook issues — is there a common thread?"

> "What problem records would you recommend we raise based on this data?"

> "Which trend has the highest impact and should be prioritised first?"

## Answer Key (Facilitator Only)

The dataset contains **4 embedded trends**. A good agent should identify at least 3 of these.

### Trend 1 — Outlook Crashes Linked to KB5041585
- **What:** ~40 Outlook crash/freeze tickets clustered between 12 Nov – 3 Dec 2025
- **Hidden signal:** The tickets are spread across every department and location, so grouping by org unit doesn't reveal the pattern. The common thread is temporal — they all appeared within 3 weeks of a Windows cumulative update (KB5041585). Some engineer comments mention the KB, but most attribute the issue to generic causes (profile corruption, add-in conflicts, etc.)
- **Why it's hard to spot manually:** Different symptoms, different engineers, different root causes recorded. You'd need to read the comments and correlate with the date window.
- **Recommended action:** Raise a Problem Record targeting KB5041585 interaction with Outlook. Engage Desktop Engineering to test rollback or apply a targeted fix.

### Trend 2 — OneDrive Sync Failures on VLAN-230
- **What:** ~35 OneDrive sync failure tickets where the user is on network segment VLAN-230
- **Hidden signal:** VLAN-230 serves Leeds HQ Floor 3 and Redditch Office. The tickets come from many different departments, so grouping by team doesn't help. The common field is `Network Segment = VLAN-230`. Most tickets cluster between Dec 2025 – Jan 2026, suggesting a firewall or network change around that time.
- **Why it's hard to spot manually:** Engineers are logging varied root causes (client corruption, cache issues, auth token expiry). The network segment field isn't something most analysts would think to pivot on.
- **Recommended action:** Raise a Problem Record for VLAN-230 OneDrive connectivity. Engage Network/Firewall team to audit recent rule changes affecting Microsoft sync endpoints on that segment.

### Trend 3 — Teams Call Quality Degradation via PROXY-UK-02
- **What:** ~30 Teams call quality tickets where user traffic routes through PROXY-UK-02
- **Hidden signal:** The symptoms vary widely (audio dropout, video freeze, call drops, latency). Users are in different locations and on different VLANs. The common infrastructure component is `Proxy = PROXY-UK-02`. Several engineer comments note proxy-related latency but this hasn't been connected across tickets.
- **Why it's hard to spot manually:** The proxy field isn't a natural grouping for service desk data. You'd need to cross-reference proxy assignment with call quality complaints — a non-obvious correlation.
- **Recommended action:** Raise a Problem Record for Teams media traffic routing through PROXY-UK-02. Engage Infrastructure team to investigate whether TLS inspection is being applied to real-time media streams (Microsoft recommends direct/bypass routing for Teams media).

### Trend 4 — SharePoint Permission Errors Post-Migration (Project Atlas)
- **What:** ~25 SharePoint access/permission error tickets all opened within 2 weeks of 20 Jan 2026
- **Hidden signal:** All relate to sites migrated during "Project Atlas" tenant consolidation. Engineer comments reference unresolved SIDs, broken group mappings, and migration-related issues. The temporal clustering (late Jan – early Feb 2026) and references to migration in comments are the key signals.
- **Why it's hard to spot manually:** The tickets are categorised under generic SharePoint permission errors. Without reading the engineer comments and noticing the migration references, they look like unrelated access issues.
- **Recommended action:** Raise a Problem Record linked to Project Atlas migration batch 3. Engage the Migration/Identity team to audit and remap security group SIDs across all migrated site collections.

## Discussion Points for the Session

After the agent presents its findings, facilitate a conversation around:

1. **Value of AI in Problem Management** — How long would it take a human analyst to cross-reference 500 tickets across 15 fields and free-text comments? The agent does it in seconds.

2. **The importance of the system prompt** — Try removing parts of the system prompt and re-running. How does the agent's analysis change? This demonstrates why prompt engineering matters.

3. **Data quality matters** — The trends are discoverable because the data includes network segment and proxy fields. In real life, what additional fields would make service desk data more analysable?

4. **From Incident to Problem** — Each trend represents a shift from reactive incident management to proactive problem management. Discuss how this fits into your ITIL processes.

5. **Limitations** — The agent identifies correlations, not confirmed causes. Human expertise is still needed to validate and act. AI augments the analyst, it doesn't replace them.
