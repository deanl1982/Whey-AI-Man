# Ollama Prompts Guide

Guide to crafting effective prompts for disk space analysis with Ollama (Llama2).

---

## Basic Prompt Structure

### Anatomy of a Good Prompt

```
[Role] You are a [specific role with context]

[Task] [Clear instruction about what to do]

[Data] [Relevant data to analyze]

[Constraints] [Format, limitations, what NOT to do]

[Example] (optional) Example: /tmp/logs
```

---

## Prompt Templates

### Template 1: Simple Path Identification

**Use Case:** LLM identifies which directory to clean.

```
You are a Linux sysadmin. The /tmp directory is at {{ $json.disk_usage_percent }}% usage. Here are the largest items:

{{ $json.disk_analysis }}

Based on this, what directory should we clean up? Respond with ONLY the path, nothing else. Example: /tmp/logs
```

**Why it works:**
- ✅ Clear role (Linux sysadmin)
- ✅ Context (disk usage percentage)
- ✅ Data (du output)
- ✅ Specific output format (path only)
- ✅ Example provided

**Expected Response:**
```
/tmp/logs
```

---

### Template 2: Safety-Aware Selection

**Use Case:** LLM considers file importance before suggesting cleanup.

```
You are a cautious Linux sysadmin managing a production server. The /tmp directory is at {{ $json.disk_usage_percent }}% usage.

Here are the largest items:
{{ $json.disk_analysis }}

Guidelines:
- NEVER suggest cleaning /tmp/data (contains database files)
- /tmp/cache and /tmp/logs are safe to clean
- Prefer cache files over logs

Which directory should we clean? Respond with ONLY the path.
```

**Why it works:**
- ✅ Emphasizes safety ("cautious", "production")
- ✅ Provides explicit rules
- ✅ Prioritizes safe options

**Expected Response:**
```
/tmp/cache
```

---

### Template 3: File-Specific Selection

**Use Case:** Choose specific file instead of entire directory.

```
You are a Linux sysadmin. The /tmp/logs directory has these files:

{{ $json.files_list }}

All are log files. Which specific file is safest to delete? Consider:
- app.log is actively written to (don't delete)
- old.log is from last month (can delete)
- archive-2020.log is very old (safe to delete)

Respond with the full path of ONE file to delete.
```

**Why it works:**
- ✅ Provides context about each file
- ✅ Explains what's currently in use
- ✅ Guides toward best choice

**Expected Response:**
```
/tmp/logs/archive-2020.log
```

---

### Template 4: Action Recommendation

**Use Case:** LLM suggests command to run, not just path.

```
You are a DevOps engineer. The /tmp directory is at {{ $json.disk_usage_percent }}% usage.

Disk analysis shows:
{{ $json.disk_analysis }}

What find command should we run to clean up old files? Provide:
1. The directory to target
2. The exact find command

Format:
Directory: /path/here
Command: find /path/here -type f -mtime +30 -delete
```

**Why it works:**
- ✅ Requests structured output
- ✅ Gets both path and command
- ✅ Provides format example

**Expected Response:**
```
Directory: /tmp/logs
Command: find /tmp/logs -type f -mtime +7 -delete
```

---

### Template 5: JSON Response

**Use Case:** Structured response for easier parsing.

```
You are a Linux sysadmin AI assistant. Analyze this disk usage data:

Disk usage: {{ $json.disk_usage_percent }}%
Largest directories:
{{ $json.disk_analysis }}

Respond ONLY with valid JSON in this format:
{
  "cleanup_path": "/tmp/logs",
  "reason": "Contains old log files safe to delete",
  "estimated_space_freed_gb": 1.0,
  "risk_level": "low"
}
```

**Why it works:**
- ✅ Machine-readable output
- ✅ Multiple data points returned
- ✅ Easy to parse in n8n Code node

**Expected Response:**
```json
{
  "cleanup_path": "/tmp/logs",
  "reason": "Contains old log files safe to delete",
  "estimated_space_freed_gb": 1.0,
  "risk_level": "low"
}
```

---

## Advanced Techniques

### Few-Shot Learning

Provide examples to guide the LLM's behavior:

```
You are a Linux sysadmin. Analyze disk usage and suggest what to clean.

Example 1:
Input: 1.0G /tmp/logs, 50M /tmp/cache
Output: /tmp/logs

Example 2:
Input: 500M /tmp/data/important.db, 400M /tmp/cache
Output: /tmp/cache

Now analyze:
{{ $json.disk_analysis }}

Output:
```

**Why it works:**
- ✅ Teaches by example
- ✅ Shows desired format
- ✅ Demonstrates reasoning

---

### Chain of Thought

Ask LLM to explain reasoning:

```
You are a Linux sysadmin. The /tmp directory is at {{ $json.disk_usage_percent }}% usage.

{{ $json.disk_analysis }}

Think through this step by step:
1. Which directories are safe to clean?
2. Which contains the most space?
3. What is your recommendation?

Final answer (path only):
```

**Why it works:**
- ✅ Improves accuracy
- ✅ Can review reasoning in logs
- ✅ More reliable answers

---

### Negative Instructions

Tell LLM what NOT to do:

```
You are a Linux sysadmin. Suggest a directory to clean.

{{ $json.disk_analysis }}

IMPORTANT:
- Do NOT suggest /home, /etc, /var/lib, or /opt
- Do NOT suggest any path outside /tmp
- Do NOT provide explanations, just the path

Answer:
```

**Why it works:**
- ✅ Prevents dangerous suggestions
- ✅ Enforces safety boundaries
- ✅ Ensures correct format

---

## Prompt Engineering Tips

### 1. Be Specific
❌ Bad: "What should we do?"
✅ Good: "Which directory in /tmp should we clean? Respond with only the path."

### 2. Provide Context
❌ Bad: Here's some disk info: [data]
✅ Good: "You are a Linux admin. The disk is at 90% (critical). Here's the data: [data]"

### 3. Control Output Format
❌ Bad: "Tell me what to clean"
✅ Good: "Respond with ONLY the path to clean, nothing else. Example: /tmp/logs"

### 4. Use Examples
❌ Bad: "Give me a path"
✅ Good: "Give me a path like this example: /tmp/cache"

### 5. Set Boundaries
❌ Bad: "Which file to delete?"
✅ Good: "Which file in /tmp/logs to delete? NEVER suggest files outside /tmp."

---

## Common Issues and Solutions

### Issue 1: LLM Provides Explanation Instead of Path

**Bad Response:**
```
Based on the analysis, I recommend cleaning the /tmp/logs directory because it contains old log files that are taking up significant space...
```

**Solution:**
```
Respond with ONLY the path, nothing else. Do not explain.
Example: /tmp/logs
```

---

### Issue 2: LLM Suggests Dangerous Path

**Bad Response:**
```
/home/user
```

**Solution:**
```
CRITICAL: Only suggest paths in /tmp. Never suggest /home, /etc, /var/lib, /opt, or /root.
```

---

### Issue 3: LLM Returns JSON in Markdown

**Bad Response:**
```
json
{ "path": "/tmp/logs" }

```

**Solution:**
```
Respond with valid JSON only. Do not use markdown code blocks. Start with { and end with }.
```

---

### Issue 4: Response Too Long

**Bad Response:**
```
After careful analysis of the disk usage patterns and considering various factors including file age, access patterns, and potential impact on running systems...
```

**Solution:**
```
Respond with maximum 10 words. Just the path: /tmp/logs
```

---

## Testing Prompts

### Test Command (Bash)

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "You are a Linux sysadmin. The /tmp directory is at 87% usage. Largest item: 1.0G /tmp/logs. What should we clean? Respond with ONLY the path.",
  "stream": false
}'
```

### Test in n8n

1. Add HTTP Request node
2. Configure as POST to `http://localhost:11434/api/generate`
3. Body:
```json
{
  "model": "llama2",
  "prompt": "Your test prompt here",
  "stream": false
}
```
4. Execute and view response

---

## Prompt Parameters (Ollama API)

```json
{
  "model": "llama2",
  "prompt": "Your prompt here",
  "stream": false,
  "temperature": 0.7,
  "max_tokens": 100
}
```

**Parameters:**
- **model:** Which model to use (llama2, llama3, etc.)
- **stream:** false = wait for complete response (easier to parse)
- **temperature:** 0.0 = deterministic, 1.0 = creative (use 0.1-0.3 for factual tasks)
- **max_tokens:** Limit response length
- **top_p:** Alternative to temperature (0.1 = focused, 0.9 = diverse)
- **top_k:** Consider only top K probable tokens

**For disk cleanup:**
- Use `temperature: 0.1` (we want consistent, predictable answers)
- Use `max_tokens: 50` (we just need a path)
- Use `stream: false` (easier parsing in n8n)

---

## Prompt Library

### Quick Reference

**Simple path selection:**
```
Disk at {{ $json.percent }}%. Top items: {{ $json.items }}.
What to clean? Path only. Example: /tmp/logs
```

**With safety:**
```
{{ $json.items }}
Safe to clean: /tmp/cache, /tmp/logs
NEVER: /home, /etc, /var/lib
Which to clean? Path only.
```

**JSON response:**
```
Disk analysis: {{ $json.items }}
Respond in JSON: {"path": "/tmp/logs", "reason": "old logs"}
```

**Multiple options:**
```
Rank these by priority to clean (1=highest):
{{ $json.items }}
Format: 1. /path/one, 2. /path/two
```

---

## Production Considerations

### 1. Validate LLM Output

Always validate before executing:

```javascript
const path = $json.llm_response.trim();

// Whitelist check
const safePaths = ['/tmp/logs', '/tmp/cache', '/var/tmp'];
if (!safePaths.some(safe => path.startsWith(safe))) {
    throw new Error(`Unsafe path suggested: ${path}`);
}

// Blocklist check
const dangerousPaths = ['/home', '/etc', '/var/lib', '/root'];
if (dangerousPaths.some(danger => path.includes(danger))) {
    throw new Error(`Dangerous path blocked: ${path}`);
}

return [{ json: { validated_path: path }}];
```

### 2. Fallback Logic

If LLM fails, use simple rules:

```javascript
try {
    // Try LLM analysis
    const llmPath = callOllama(prompt);
    return llmPath;
} catch (error) {
    // Fallback: Use largest directory in /tmp/logs
    return '/tmp/logs';
}
```

### 3. Human Approval

For critical systems, require human approval:

```
[LLM Suggests] → [Notify Admin] → [Wait for Approval] → [Execute]
```

---

## Additional Resources

- [Ollama API Documentation](https://github.com/ollama/ollama/blob/main/docs/api.md)
- [Prompt Engineering Guide](https://www.promptingguide.ai/)
- [Llama 2 Model Card](https://huggingface.co/meta-llama/Llama-2-7b)

---

*Return to [Lab Guide](../lab-guide.md)*
