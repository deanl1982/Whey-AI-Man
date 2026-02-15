# Workflow Architecture

Visual guide to the Disk Space Cleanup workflow structure.

---

## Complete Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    DISK SPACE CLEANUP WORKFLOW                   │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│  Schedule Trigger│  Runs every 60 seconds
│   (Every 60s)    │
└────────┬─────────┘
         │
         v
┌────────────────────┐
│  Execute Command   │  Command: df -h /tmp | tail -1 | awk '{print $5}'
│  (Check Disk)      │  Output: "87%"
└────────┬───────────┘
         │
         v
┌────────────────────┐
│   Code Node        │  Parse "87%" → 87
│  (Parse Percent)   │  Output: { disk_usage_percent: 87 }
└────────┬───────────┘
         │
         v
┌────────────────────┐
│     IF Node        │  Condition: disk_usage_percent > 85?
│  (Check Threshold) │
└─────┬──────────┬───┘
      │          │
 FALSE│          │TRUE (Continue to cleanup)
      │          │
      v          v
   ┌─────┐  ┌─────────────────────┐
   │ END │  │  Execute Command     │  Command: du -sh /tmp/* | sort -rh | head -10
   └─────┘  │ (Analyze Space)      │  Output: "1.0G  /tmp/logs\n50M  /tmp/cache..."
            └──────────┬───────────┘
                       │
                       v
            ┌──────────────────────┐
            │   HTTP Request       │  POST to Ollama API
            │  (Call LLM)          │  Prompt: "What should we clean?"
            │                      │  Response: "/tmp/logs"
            └──────────┬───────────┘
                       │
                       v
            ┌──────────────────────┐
            │   Code Node          │  Parse LLM response
            │ (Parse Response)     │  Extract path: "/tmp/logs"
            └──────────┬───────────┘
                       │
                       v
            ┌──────────────────────┐
            │  Execute Command     │  Command: find /tmp/logs -type f -mtime +7 -delete
            │ (Run Cleanup)        │  Deletes old files
            └──────────┬───────────┘
                       │
                       v
            ┌──────────────────────┐
            │  Execute Command     │  Command: df -h /tmp | tail -1 | awk '{print $5}'
            │ (Verify)             │  Output: "67%" (reduced!)
            └──────────┬───────────┘
                       │
                       v
            ┌──────────────────────┐
            │   Code Node          │  Format results
            │ (Format Notification)│  "Before: 87%, After: 67%, Freed: 20%"
            └──────────┬───────────┘
                       │
                       v
                    ┌─────┐
                    │ END │
                    └─────┘
```

---

## Workflow Phases

### Phase 1: Monitor (Always Runs)
```
Schedule Trigger (60s) → Check Disk (df) → Parse Percentage
```
**Purpose:** Continuously monitor disk usage.
**Output:** Numeric percentage (e.g., 87)

---

### Phase 2: Evaluate (Decision Point)
```
IF Node: disk_usage_percent > 85?
├─ FALSE → End workflow (disk space is fine)
└─ TRUE → Continue to cleanup
```
**Purpose:** Only proceed if action is needed.
**Logic:** Threshold-based trigger.

---

### Phase 3: Analyze (AI-Powered)
```
Analyze Space (du) → Call LLM → Parse Response
```
**Purpose:** Intelligently identify what to clean.
**Data Flow:**
- Input: `du` output (space usage list)
- Processing: LLM analysis
- Output: Path to clean (e.g., "/tmp/logs")

---

### Phase 4: Remediate (Automated Action)
```
Run Cleanup (find -delete)
```
**Purpose:** Execute the cleanup command.
**Safety:** Only runs on path suggested by LLM.

---

### Phase 5: Verify (Confirmation)
```
Verify (df) → Format Notification
```
**Purpose:** Confirm cleanup succeeded and report results.
**Output:** Before/after comparison.

---

## Data Flow

### Node-to-Node Data Passing

```
┌──────────────┐     { stdout: "87%\n", exitCode: 0 }
│ Check Disk   │─────────────────────────────────────┐
└──────────────┘                                      │
                                                      v
                                          ┌─────────────────────┐
                                          │  Parse Percentage   │
                                          └──────────┬──────────┘
                                                     │
                              { disk_usage_percent: 87 }
                                                     │
                                                     v
                                          ┌─────────────────────┐
                                          │    IF Node          │
                                          └─────────────────────┘
```

### Expression References

Nodes can reference previous nodes by name:

```javascript
// In "Parse Response" node, reference "IF" node data:
const usageBefore = $('IF').item.json.disk_usage_percent;

// In "Format Notification" node, reference multiple nodes:
const before = $('IF').item.json.disk_usage_percent;
const after = $json.new_usage;
const freed = before - after;
```

---

## Alternative Workflows

### Simplified Version (No LLM)

For faster/simpler execution without AI:

```
Schedule → Check Disk → IF > 85% → find /tmp/logs -mtime +7 -delete → Verify
```

**Pros:**
- Faster (no LLM call)
- More predictable
- Simpler logic

**Cons:**
- Always targets same path
- Less intelligent
- Can't adapt to different scenarios

---

### Multi-Threshold Version

Different actions based on severity:

```
Schedule → Check Disk → SWITCH Node
                         ├─ 80-85%: Delete files > 30 days
                         ├─ 85-90%: Delete files > 14 days
                         ├─ 90-95%: Delete files > 7 days
                         └─ 95%+:   Alert admin (don't auto-delete)
```

**Use Case:** Graduated response based on severity.

---

### Human Approval Version

Requires confirmation before execution:

```
LLM Suggests → Send Email/Slack → Wait for Webhook Response → Execute if Approved
```

**Use Case:** Production systems requiring human oversight.

---

### Multi-Directory Version

Checks multiple directories:

```
Schedule → Check Disk → IF > 85%
                         ├─ Analyze /tmp
                         ├─ Analyze /var/log
                         ├─ Analyze /var/cache
                         └─ Clean highest priority
```

**Use Case:** Comprehensive disk management.

---

## Error Handling Paths

### With Error Handling

```
┌──────────────────┐
│  Execute Cleanup │
└────────┬─────────┘
         │
    ┌────┴────┐
    │         │
SUCCESS     ERROR
    │         │
    v         v
┌────────┐ ┌─────────┐
│ Verify │ │ Log     │
│ Success│ │ Error & │
└────────┘ │ Alert   │
           └─────────┘
```

### Error Handling in n8n

**Method 1: Try/Catch in Code Node**
```javascript
try {
    // Execute cleanup logic
    const result = executeCleanup();
    return [{ json: { success: true, result }}];
} catch (error) {
    return [{ json: { success: false, error: error.message }}];
}
```

**Method 2: On Error Workflow**
Configure "On Error" settings in each node to route failures to error handler.

---

## Performance Considerations

### Current Timing (Estimated)

```
Schedule Trigger:        0s (instant)
Check Disk (df):        ~0.1s
Parse Percentage:       ~0.05s
IF Check:              ~0.01s
Analyze Space (du):     ~0.5s (depends on file count)
Call LLM:              ~2-5s (model dependent)
Parse Response:        ~0.05s
Run Cleanup:           ~0.5-2s (depends on files deleted)
Verify:                ~0.1s
Format Notification:    ~0.05s
───────────────────────────────────
TOTAL:                 ~3-8 seconds
```

### Optimization Tips

**1. Reduce LLM Latency:**
- Use faster model (if available)
- Reduce max_tokens in request
- Lower temperature for faster generation

**2. Parallelize Independent Operations:**
- Can't parallelize sequential operations
- Could check multiple directories in parallel

**3. Cache Results:**
- Cache du output if running frequently
- Only re-analyze if disk usage changes significantly

---

## Deployment Patterns

### Development Setup
```
Manual Trigger → Build & Test → Manual Execution
```

### Staging Setup
```
Schedule (every 5 mins) → Test with low threshold (60%) → Slack notifications
```

### Production Setup
```
Schedule (every 60s) → Threshold 85% → Human approval → Cleanup → Alert → Log to database
```

---

## Monitoring & Observability

### What to Log

1. **Execution Metadata:**
   - Timestamp
   - Disk usage before/after
   - Space freed
   - Path cleaned

2. **LLM Data:**
   - Prompt sent
   - Response received
   - Confidence/reasoning

3. **Errors:**
   - Failed commands
   - LLM timeouts
   - Invalid paths suggested

### Logging Pattern

```javascript
const logEntry = {
    timestamp: new Date().toISOString(),
    usage_before: $('IF').item.json.disk_usage_percent,
    usage_after: $json.new_usage,
    space_freed: freed,
    path_cleaned: $('Parse Response').item.json.cleanup_path,
    success: true
};

// Send to logging service or store in DB
console.log(JSON.stringify(logEntry));
```

---

## Security Considerations

### Path Validation

**Whitelist Approach:**
```javascript
const allowedPaths = ['/tmp', '/var/tmp', '/var/cache'];
const suggestedPath = $json.llm_path;

if (!allowedPaths.some(p => suggestedPath.startsWith(p))) {
    throw new Error('Path not in whitelist');
}
```

**Blocklist Approach:**
```javascript
const blockedPaths = ['/home', '/etc', '/root', '/var/lib'];
const suggestedPath = $json.llm_path;

if (blockedPaths.some(p => suggestedPath.includes(p))) {
    throw new Error('Dangerous path blocked');
}
```

### Command Injection Prevention

```javascript
// BAD: Direct interpolation
const command = `find ${userInput} -delete`;  // ⚠️ VULNERABLE

// GOOD: Validate first
const safePath = validatePath(userInput);
const command = `find ${safePath} -delete`;  // ✅ SAFE
```

---

## Workflow Variations by Use Case

### Use Case 1: Log Rotation
**Target:** `/var/log`
**Threshold:** 80%
**Strategy:** Compress old logs, then delete if still full
**Schedule:** Daily at 2 AM

### Use Case 2: Temp File Cleanup
**Target:** `/tmp`, `/var/tmp`
**Threshold:** 85%
**Strategy:** Delete files >7 days old
**Schedule:** Every hour

### Use Case 3: Docker Cleanup
**Target:** Docker images/containers
**Threshold:** 90%
**Strategy:** Prune unused images/containers
**Schedule:** Weekly

### Use Case 4: User Downloads
**Target:** `/home/*/Downloads`
**Threshold:** Per-user 5GB limit
**Strategy:** Email user, then archive after 30 days
**Schedule:** Daily scan

---

## Additional Resources

- [n8n Workflow Examples](https://n8n.io/workflows)
- [Mermaid Diagram Syntax](https://mermaid.js.org/)
- [Flowchart Best Practices](https://www.lucidchart.com/pages/flowchart-tips)

---

*Return to [Lab Guide](../lab-guide.md)*
