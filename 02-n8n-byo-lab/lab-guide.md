# Lab Guide: Intelligent Disk Space Cleanup with n8n and AI

**Duration:** 45 minutes
**Difficulty:** Beginner
**Tools:** n8n, Ollama (Llama2), Linux

---

## Part 1: Environment Setup (5 minutes)

### Step 1.1: Verify n8n is Running

Open your web browser and navigate to:
```
http://YOUR_VM_IP:5678
```

You should see the n8n welcome screen. If prompted, create a new account (local only, no external registration needed).

### Step 1.2: Verify Ollama is Installed

SSH into your VM and run:
```bash
ollama list
```

**Expected output:**
```
NAME            ID              SIZE      MODIFIED
llama2:latest   xxxxxxxxxxxx    3.8 GB    X minutes ago
```

If you don't see llama2, run:
```bash
ollama pull llama2
```

### Step 1.3: Test Ollama API

Run this test command:
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "Say: Ollama is ready!",
  "stream": false
}'
```

You should get a JSON response containing "Ollama is ready!" in the output.

### Step 1.4: Create Test Files

Create large test files to simulate disk space issues:
```bash
cd /tmp
mkdir -p logs
dd if=/dev/zero of=/tmp/logs/app.log bs=1M count=500
dd if=/dev/zero of=/tmp/logs/old.log bs=1M count=300
dd if=/dev/zero of=/tmp/logs/archive-2020.log bs=1M count=200
```

**Verify files created:**
```bash
du -sh /tmp/logs/*
```

**Expected output:**
```
500M    /tmp/logs/app.log
300M    /tmp/logs/old.log
200M    /tmp/logs/archive-2020.log
```

### Step 1.5: Check Disk Usage

```bash
df -h /tmp
```

Note the **Use%** column - this is what our workflow will monitor.

---

## Part 2: n8n Quick Tour (3 minutes)

### Understanding the n8n Interface

1. **Left Sidebar:**
   - Search for nodes
   - Categories: Triggers, Actions, Helpers

2. **Canvas (Center):**
   - Drag nodes here
   - Connect nodes with lines
   - Click nodes to configure

3. **Top Bar:**
   - **Save:** Save your workflow
   - **Execute Workflow:** Run it manually
   - **Active/Inactive:** Toggle automatic execution

### Key Concepts

- **Node:** A single step in your workflow (trigger, action, decision)
- **Connection:** The flow between nodes
- **Execution:** A single run of the workflow
- **Data:** Passes from node to node as JSON

---

## Part 3: Build the Workflow (20 minutes)

### Step 3.1: Create New Workflow (1 min)

1. Click **"Add workflow"** in the top-left
2. Name it: **"Disk Space Cleanup"**
3. Save it (Ctrl+S or top-right Save button)

---

### Step 3.2: Add Schedule Trigger (2 mins)

**What it does:** Runs the workflow every 60 seconds automatically.

1. Click **"+"** or search for nodes
2. Search for **"Schedule Trigger"**
3. Click to add it to canvas

**Configuration:**
- **Mode:** "Every X"
- **Value:** 60
- **Unit:** Seconds

**Test it:**
- Click **"Test step"** to see it execute
- You should see output with timestamp

---

### Step 3.3: Check Disk Usage (4 mins)

**What it does:** Executes shell command to get disk usage percentage.

1. Add **"Execute Command"** node (search for it)
2. Connect Schedule Trigger → Execute Command (drag from dot to dot)

**Configuration:**
- **Command:**
  ```bash
  df -h /tmp | tail -1 | awk '{print $5}'
  ```

**What this does:**
- `df -h /tmp` - Shows disk usage for /tmp
- `tail -1` - Gets last line only
- `awk '{print $5}'` - Extracts 5th column (percentage like "87%")

**Test it:**
1. Click **"Execute node"**
2. View output tab - should show something like **"45%"** or **"67%"**

---

### Step 3.4: Parse Percentage (3 mins)

**What it does:** Extracts numeric value from "87%" → 87

1. Add **"Code"** node
2. Connect Execute Command → Code

**Configuration:**
- **Mode:** "Run Once for All Items"
- **JavaScript Code:**
  ```javascript
  // Extract percentage from stdout
  const stdout = $input.first().json.stdout;
  const percentStr = stdout.trim().replace('%', '');
  const percent = parseInt(percentStr);

  return [{
    json: {
      disk_usage_percent: percent,
      disk_usage_raw: stdout.trim()
    }
  }];
  ```

**Alternative (simpler):**
If you prefer, use a **"Set"** node instead:
- **Value:** `{{ $json.stdout.replace('%', '').trim() }}`
- **Name:** `disk_usage_percent`

**Test it:**
- Execute node
- Output should show: `{ "disk_usage_percent": 67, "disk_usage_raw": "67%" }`

---

### Step 3.5: Conditional Branch (2 mins)

**What it does:** Only proceeds with cleanup if usage > 85%.

1. Add **"IF"** node
2. Connect Code → IF

**Configuration:**
- **Conditions:**
  - **Value 1:** `{{ $json.disk_usage_percent }}`
  - **Operation:** "Larger"
  - **Value 2:** 85

**What happens:**
- **True path:** Disk is too full, continue to cleanup
- **False path:** Disk is fine, end workflow

**Test it:**
- Execute node
- If usage < 85%, it goes to "false" path
- If usage > 85%, it goes to "true" path

**Note:** For testing, you might want to temporarily set threshold to 40 or 50 so cleanup always runs.

---

### Step 3.6: Analyze Disk Usage (3 mins)

**What it does:** Runs `du` command to see what's using space.

1. Add **"Execute Command"** node (on TRUE path from IF)
2. Connect IF (true) → Execute Command

**Configuration:**
- **Command:**
  ```bash
  du -sh /tmp/* 2>/dev/null | sort -rh | head -10
  ```

**What this does:**
- `du -sh /tmp/*` - Show size of each item in /tmp
- `2>/dev/null` - Hide error messages
- `sort -rh` - Sort by size (largest first)
- `head -10` - Show top 10

**Test it:**
- Execute node
- Output shows something like:
  ```
  1.0G    /tmp/logs
  50M     /tmp/systemd-private-xxx
  12M     /tmp/snap.docker
  ```

---

### Step 3.7: Call Ollama for AI Analysis (6 mins)

**What it does:** Uses AI to analyze disk usage and suggest what to clean.

1. Add **"HTTP Request"** node
2. Connect previous Execute Command → HTTP Request

**Configuration:**
- **Method:** POST
- **URL:** `http://localhost:11434/api/generate`
- **Send Body:** Yes (JSON)
- **Body (Specify):** Enter this JSON:

```json
{
  "model": "llama2",
  "prompt": "You are a Linux sysadmin. The /tmp directory is at {{ $('IF').item.json.disk_usage_percent }}% usage. Here are the largest items:\n\n{{ $json.stdout }}\n\nBased on this, what directory should we clean up? Respond with ONLY the full path to clean, nothing else. Example: /tmp/logs",
  "stream": false
}
```

**Understanding the Prompt:**
- **Context:** Tells LLM it's a Linux admin
- **Data:** Provides disk percentage and du output
- **Instruction:** Asks for path to clean
- **Format:** Requests simple path only (for easy parsing)

**Test it:**
1. Execute node
2. View output - look for **"response"** field
3. Should contain: `/tmp/logs` or similar path

---

### Step 3.8: Parse LLM Response (2 mins)

**What it does:** Extracts the path from LLM's JSON response.

1. Add **"Code"** node
2. Connect HTTP Request → Code

**JavaScript Code:**
```javascript
// Parse Ollama response
const ollamaResponse = $input.first().json.response;
const cleanupPath = ollamaResponse.trim();

return [{
  json: {
    cleanup_path: cleanupPath,
    disk_usage_before: $('IF').item.json.disk_usage_percent
  }
}];
```

**Test it:**
- Execute node
- Output should show: `{ "cleanup_path": "/tmp/logs", "disk_usage_before": 87 }`

---

### Step 3.9: Execute Cleanup (4 mins)

**What it does:** Deletes old files in the identified directory.

1. Add **"Execute Command"** node
2. Connect Code → Execute Command

**Configuration:**
- **Command:**
  ```bash
  find {{ $json.cleanup_path }} -type f -mtime +7 -delete
  ```

**What this does:**
- `find <path>` - Search in this directory
- `-type f` - Only files (not directories)
- `-mtime +7` - Modified more than 7 days ago
- `-delete` - Delete them

**⚠️ Safety Note:**
This deletes files! In production, you'd want:
- Whitelist of safe paths only
- Move to archive instead of delete
- Human approval for certain paths

**Alternative (safer for testing):**
Just list files instead of deleting:
```bash
find {{ $json.cleanup_path }} -type f -mtime +7
```

Then manually delete:
```bash
rm /tmp/logs/*.log
```

---

### Step 3.10: Verify & Notify (3 mins)

**What it does:** Re-checks disk usage and reports results.

1. Add **"Execute Command"** node
2. Connect previous Execute Command → this new one

**Configuration:**
- **Command:**
  ```bash
  df -h /tmp | tail -1 | awk '{print $5}'
  ```

**Then add a Code node to format the result:**

Connect Execute Command → Code

**JavaScript Code:**
```javascript
const usageAfter = parseInt($json.stdout.replace('%', '').trim());
const usageBefore = $('Code1').item.json.disk_usage_before;
const cleaned = usageBefore - usageAfter;
const cleanupPath = $('Code1').item.json.cleanup_path;

const message = `✅ Disk Space Cleanup Complete

Before: ${usageBefore}%
After: ${usageAfter}%
Space Freed: ~${cleaned}%
Cleaned: ${cleanupPath}
Timestamp: ${new Date().toISOString()}`;

console.log(message);

return [{ json: {
  message,
  usageBefore,
  usageAfter,
  spaceFried: cleaned
}}];
```

**Test it:**
- Execute workflow from start
- Check output of final node
- Should show before/after comparison

---

## Part 4: Test the Complete Workflow (12 minutes)

### Test 1: Full Run with Disk Full

1. **Fill disk again:**
   ```bash
   dd if=/dev/zero of=/tmp/logs/test.log bs=1M count=500
   ```

2. **Check usage:**
   ```bash
   df -h /tmp
   ```

3. **Run workflow:**
   - Click **"Execute Workflow"** at top
   - Watch each node execute in sequence

4. **Verify cleanup:**
   ```bash
   df -h /tmp
   ls -lh /tmp/logs/
   ```

**Expected Result:**
- Workflow detects high usage (>85%)
- LLM suggests `/tmp/logs`
- Old files deleted
- Disk usage drops

---

### Test 2: Second Run (Disk OK)

1. **Run workflow again** (click Execute Workflow)

2. **Expected behavior:**
   - Check disk usage: Now below 85%
   - IF node goes to FALSE path
   - Workflow ends early (no cleanup needed)
   - Logs show "Disk space OK"

---

### Test 3: Automatic Execution

1. **Toggle workflow to Active** (switch at top)
2. **Wait 60 seconds**
3. **Check executions list** (left sidebar)
4. **See automatic runs** every minute

---

## Part 5: Discussion & Q&A (5 minutes)

### Questions to Consider

**1. What if LLM suggests the wrong path?**
- Add path validation (whitelist/blacklist)
- Require human approval for critical paths
- Only allow cleanup in designated directories

**2. How to make this production-safe?**
- Archive files instead of deleting
- Require 2 consecutive high-usage detections
- Set maximum cleanup amount (never delete >1GB at once)
- Add approval workflow for certain paths

**3. What other strategies could we use?**
- Compress old logs (gzip) instead of deleting
- Archive to Azure Blob Storage
- Different retention policies per file type
- Email weekly report of cleanup actions

**4. How does this translate to Azure?**
- **Azure VMs:** Monitor C: or /var disk usage
- **App Service:** Cleanup application logs
- **Storage Accounts:** Lifecycle management
- **Container Registry:** Remove old images
- **AKS:** Monitor persistent volume usage

### Real-World Scenarios

Where could you use this pattern?
- Web server logs filling `/var/log`
- Docker build cache on CI/CD servers
- Temporary processing files in data pipelines
- Database backup archives
- Application temp files

---

## Troubleshooting

### Ollama Not Responding
```bash
# Check if Ollama is running
ps aux | grep ollama

# Restart Ollama
sudo systemctl restart ollama

# Or run manually
ollama serve
```

### n8n Can't Execute Commands
```bash
# Check Docker container permissions
docker exec -it n8n whoami

# May need to run n8n with different user
# Or mount Docker socket
```

### Disk Space Still Full
```bash
# Manually check what's using space
du -sh /tmp/* | sort -rh | head -10

# Delete test files manually
rm -rf /tmp/logs/*.log

# Clear Docker cache if needed
docker system prune -a
```

### LLM Gives Wrong Response
- Try rephrasing the prompt
- Add more specific instructions
- Use examples in the prompt
- Consider using a different model (llama3 if available)

---

## Next Steps

1. **Export your workflow:**
   - Click "..." menu → Download workflow
   - Save as JSON for future use

2. **Explore extensions:**
   - See [extensions/advanced-challenges.md](extensions/advanced-challenges.md)
   - Multi-tier cleanup thresholds
   - Archive instead of delete
   - Integration with Azure Monitor

3. **Adapt for your environment:**
   - Change paths to match your servers
   - Adjust thresholds (maybe 80% instead of 85%)
   - Add notification to Slack/Teams/Email
   - Store cleanup logs for auditing

---

## Congratulations!

You've built an intelligent disk space cleanup automation with n8n and AI! 🎉

You now understand:
- ✅ How to build n8n workflows
- ✅ Using schedule triggers for monitoring
- ✅ Executing shell commands from automation
- ✅ Integrating LLMs for intelligent decisions
- ✅ The monitor → detect → analyze → remediate pattern

This same pattern applies to countless infrastructure automation scenarios. What will you automate next?

---

## Reference Materials

- [n8n Nodes Reference](reference/n8n-nodes-reference.md)
- [Linux Commands Cheatsheet](reference/linux-commands-cheatsheet.md)
- [Ollama Prompts Guide](reference/ollama-prompts.md)
- [Workflow Architecture](reference/workflow-architecture.md)
- [Advanced Challenges](extensions/advanced-challenges.md)
