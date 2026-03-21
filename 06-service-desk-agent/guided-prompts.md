# Guided Prompt Sequence — Service Desk Trend Analysis

Use these prompts in order during the lab session. Each stage builds on the previous one, taking the team from basic data orientation through to actionable Problem Management recommendations.

Allow the agent to respond fully before moving to the next prompt. Pause between stages to discuss what the agent found and what the team notices.

---

## Stage 1 — Orient (Understanding the data)

**Prompt 1.1:**
> I've uploaded an extract of our M365 support tickets from ServiceNow. Can you give me an overview of the dataset — how many tickets, the date range, and a breakdown by category and priority?

*What this does:* Gets the agent to confirm it can read the data and gives the team a baseline understanding of volume and shape. Nothing clever yet — just orientation.

**Prompt 1.2:**
> Which subcategories have the highest ticket volumes, and are there any months that stand out as particularly busy?

*What this does:* Starts to surface basic patterns. The team should see Outlook Desktop and Microsoft Teams near the top. The Nov–Dec 2025 period should show a spike. This is the kind of analysis a human could do in Excel — sets the stage for where AI goes further.

---

## Stage 2 — Explore (Looking for patterns)

**Prompt 2.1:**
> Look at the Outlook Desktop tickets more closely. Is there anything unusual about when they were logged or what the engineers noted in their comments?

*What this does:* Narrows focus onto the Outlook cluster. The agent should start picking up the Nov–Dec 2025 concentration and may reference KB5041585 from the engineer comments. This is the first "aha" moment — the team will see the agent reading free-text comments and correlating them with timestamps.

**Prompt 2.2:**
> Interesting. Now look beyond the obvious categories. Are there any patterns when you cross-reference tickets against infrastructure fields like network segment, proxy server, or location?

*What this does:* This is the key pivot. It pushes the agent to look at fields that a human analyst wouldn't typically group by. The agent should start surfacing the VLAN-230 / OneDrive correlation and the PROXY-UK-02 / Teams correlation. This is where the "AI sees what humans miss" message really lands.

---

## Stage 3 — Deep Dive (Investigating specific trends)

**Prompt 3.1:**
> You mentioned VLAN-230 and OneDrive issues. Can you pull together all the evidence for that — which tickets, what locations are on that VLAN, and what the engineers actually said in their comments?

*What this does:* Gets the agent to build a structured case with specific ticket IDs, location mapping (Leeds Floor 3, Redditch), and comment excerpts. Shows the team how the agent can assemble an investigation brief that would take a human analyst hours.

**Prompt 3.2:**
> Do the same for the Teams call quality issues. What's the common factor, and what are the engineers saying about it?

*What this does:* Reinforces the pattern with a second example. The agent should identify PROXY-UK-02 as the common factor and pull out comments about proxy-related latency and packet loss.

**Prompt 3.3:**
> Are there any trends related to recent change activities or projects? Look at the engineer comments for any references to migrations, rollouts, or change events.

*What this does:* This should surface Trend 4 — the SharePoint permission errors linked to Project Atlas. It demonstrates the agent's ability to mine free-text comments for contextual clues that wouldn't appear in structured fields.

---

## Stage 4 — Recommend (From insight to action)

**Prompt 4.1:**
> Based on everything you've found, what Problem Records would you recommend we raise? For each one, give me the suspected root cause, the number of affected tickets, and which team should investigate.

*What this does:* Shifts from analysis to actionable output. The agent should present 3–4 structured recommendations aligned to ITIL Problem Management. This shows the team how AI can bridge the gap between incident data and proactive problem resolution.

**Prompt 4.2:**
> If we could only tackle one of these first, which would you prioritise and why?

*What this does:* Forces the agent to weigh impact, urgency, and effort. Creates a good discussion point — does the team agree with the agent's prioritisation? This reinforces the message that AI augments human judgement rather than replacing it.

---

## Stage 5 — Reflect (Wrap-up discussion)

**Prompt 5.1:**
> What additional data would make your analysis more accurate or help you spot trends earlier?

*What this does:* The agent should suggest things like change management records, CMDB data, network topology, or user device inventory. This opens a discussion about data quality and what organisations need to invest in to get the most from AI-driven analysis.

---

## Facilitator Notes

- **Pacing:** Stages 1–2 should take about 10 minutes. Stage 3 is the meat of the demo — allow 15 minutes. Stage 4–5 are the payoff — 10 minutes.
- **If the agent misses a trend:** Use a nudge prompt like *"What about SharePoint — any patterns there?"* or *"Have you looked at all the proxy servers, not just PROXY-UK-02?"*
- **If the agent finds everything too quickly:** Skip to Stage 4 and spend more time on the prioritisation discussion.
- **Key message to reinforce:** A human analyst looking at 500 tickets in a spreadsheet would likely sort by category, maybe by priority. They probably wouldn't think to pivot on network segment or proxy server. The AI doesn't have those blind spots — it considers every field equally.
