# Advanced Challenges

Extensions and enhancements for the Disk Space Cleanup Lab.

Once you've completed the basic lab, try these challenges to take your automation to the next level!

---

## Challenge 1: Safe Path Validation ⭐

**Difficulty:** Easy
**Time:** 10-15 minutes

### Goal
Add validation to prevent LLM from suggesting dangerous paths.

### Requirements
- Block paths: `/home`, `/etc`, `/var/lib`, `/root`, `/opt`
- Only allow paths starting with: `/tmp`, `/var/tmp`, `/var/cache`
- If invalid path suggested, log error and end workflow

### Implementation Hint
Add a Code node after "Parse LLM Response":

```javascript
const suggestedPath = $json.cleanup_path;

// Blocklist check
const dangerousPaths = ['/home', '/etc', '/var/lib', '/root', '/opt'];
if (dangerousPaths.some(p => suggestedPath.includes(p))) {
    throw new Error(`Dangerous path blocked: ${suggestedPath}`);
}

// Whitelist check
const safePaths = ['/tmp', '/var/tmp', '/var/cache'];
if (!safePaths.some(p => suggestedPath.startsWith(p))) {
    throw new Error(`Path not in whitelist: ${suggestedPath}`);
}

return $input.all(); // Pass through if valid
```

### Test Cases
1. Modify prompt to suggest `/home/user` - should be blocked
2. Suggest `/etc/config` - should be blocked
3. Suggest `/tmp/logs` - should pass

### Bonus
- Add logging of blocked attempts
- Send alert when dangerous path suggested

---

## Challenge 2: Archive Instead of Delete ⭐⭐

**Difficulty:** Medium
**Time:** 20-30 minutes

### Goal
Instead of deleting files, compress and archive them first.

### Requirements
- Create archive directory: `/tmp/archives`
- Compress old files into dated archive: `cleanup-YYYYMMDD.tar.gz`
- Delete original files only after successful archive
- Keep archives for 30 days

### Implementation Hint
Replace "Execute Cleanup" node with two commands:

**Node 1: Create Archive**
```bash
mkdir -p /tmp/archives && \
tar -czf /tmp/archives/cleanup-$(date +%Y%m%d-%H%M%S).tar.gz \
$(find {{ $json.cleanup_path }} -type f -mtime +7)
```

**Node 2: Delete Originals (only if archive succeeded)**
```bash
find {{ $json.cleanup_path }} -type f -mtime +7 -delete
```

**Node 3: Cleanup Old Archives**
```bash
find /tmp/archives -name "cleanup-*.tar.gz" -mtime +30 -delete
```

### Bonus
- Verify archive integrity before deleting originals
- Store archive metadata (size, file count)
- Upload archives to Azure Blob Storage

---

## Challenge 3: Multi-Tier Cleanup Strategy ⭐⭐

**Difficulty:** Medium
**Time:** 20-30 minutes

### Goal
Different cleanup strategies based on disk usage severity.

### Requirements
- 80-85%: Delete files older than 30 days
- 85-90%: Delete files older than 14 days
- 90-95%: Delete files older than 7 days
- 95%+: Alert admin, don't auto-delete

### Implementation Hint
Replace simple IF node with Switch node:

```
Switch Node:
  Case 1: disk_usage >= 95 → Alert admin
  Case 2: disk_usage >= 90 → Delete 7+ days
  Case 3: disk_usage >= 85 → Delete 14+ days
  Case 4: disk_usage >= 80 → Delete 30+ days
  Default: No action
```

Each case runs different find command:
```bash
# Case 2 (90%+)
find {{ $json.cleanup_path }} -type f -mtime +7 -delete

# Case 3 (85%+)
find {{ $json.cleanup_path }} -type f -mtime +14 -delete

# Case 4 (80%+)
find {{ $json.cleanup_path }} -type f -mtime +30 -delete
```

### Test Cases
- Set threshold to 70% and create files at different ages
- Verify correct retention policy applied

---

## Challenge 4: File Type Intelligence ⭐⭐⭐

**Difficulty:** Hard
**Time:** 30-45 minutes

### Goal
LLM categorizes files by type and applies different retention policies.

### Requirements
- `*.log` files: 7 days retention
- `*.tmp`, `*.cache`: 1 day retention
- `*.bak`: 30 days retention
- `*.db`, `*.conf`: Never auto-delete

### Implementation Hint
Modify Ollama prompt to return JSON with file categorization:

```
Analyze these files:
{{ $json.file_list }}

For each file, determine:
1. File type (log, tmp, backup, config, data)
2. Can it be deleted? (yes/no)
3. Recommended retention (1, 7, 30 days or never)

Respond in JSON format:
{
  "files": [
    {"path": "/tmp/app.log", "type": "log", "retention_days": 7},
    {"path": "/tmp/cache.tmp", "type": "cache", "retention_days": 1}
  ]
}
```

Then loop through files and apply appropriate retention.

---

## Challenge 5: Compression Before Deletion ⭐⭐

**Difficulty:** Medium
**Time:** 20-30 minutes

### Goal
Compress log files first to save space, only delete if still over threshold.

### Requirements
1. Run `gzip` on all `*.log` files older than 7 days
2. Re-check disk usage
3. If still over threshold, delete `.gz` files older than 30 days

### Implementation Hint

**Step 1: Compress**
```bash
find {{ $json.cleanup_path }} -name "*.log" -mtime +7 -exec gzip {} \;
```

**Step 2: Verify**
```bash
df -h /tmp | tail -1 | awk '{print $5}'
```

**Step 3: If Still Full**
```bash
find {{ $json.cleanup_path }} -name "*.gz" -mtime +30 -delete
```

---

## Challenge 6: Historical Tracking & Reporting ⭐⭐⭐

**Difficulty:** Hard
**Time:** 45-60 minutes

### Goal
Store cleanup history and generate weekly reports.

### Requirements
- Log every cleanup: timestamp, before/after usage, space freed, path
- Store in SQLite database or JSON file
- Generate weekly summary: total cleanups, total space freed, top paths

### Implementation Hint

**Create Log Table:**
```sql
CREATE TABLE IF NOT EXISTS cleanup_log (
  id INTEGER PRIMARY KEY,
  timestamp TEXT,
  usage_before INTEGER,
  usage_after INTEGER,
  space_freed INTEGER,
  cleanup_path TEXT
);
```

**After Each Cleanup:**
```javascript
const logEntry = {
    timestamp: new Date().toISOString(),
    usage_before: $json.usage_before,
    usage_after: $json.usage_after,
    space_freed: $json.space_freed,
    cleanup_path: $json.cleanup_path
};

// Write to file or database
fs.appendFileSync('/tmp/cleanup-log.json', JSON.stringify(logEntry) + '\n');
```

**Weekly Report (Cron: Sunday at 9 AM):**
```javascript
// Read all logs from past week
// Aggregate: total cleanups, total space freed
// Identify: most frequently cleaned paths
// Email summary to admin
```

---

## Challenge 7: Azure Monitor Integration ⭐⭐⭐

**Difficulty:** Hard
**Time:** 45-60 minutes

### Goal
Send disk usage metrics and cleanup events to Azure Monitor.

### Requirements
- Send disk usage as custom metric every 5 minutes
- Send cleanup events as logs
- Create dashboard in Azure Portal
- Alert if usage > 90% for 10+ minutes

### Implementation Hint

**Azure Monitor API Request:**
```javascript
// HTTP Request to Azure Monitor
POST https://management.azure.com/subscriptions/{id}/resourceGroups/{rg}/providers/Microsoft.Insights/metrics

Headers:
  Authorization: Bearer {{ $env.AZURE_TOKEN }}
  Content-Type: application/json

Body:
{
  "time": "{{ $now }}",
  "data": {
    "baseData": {
      "metric": "DiskUsagePercent",
      "namespace": "Custom",
      "dimNames": ["Server", "Mount"],
      "series": [{
        "dimValues": ["{{ $env.HOSTNAME }}", "/tmp"],
        "min": {{ $json.disk_usage_percent }},
        "max": {{ $json.disk_usage_percent }},
        "sum": {{ $json.disk_usage_percent }},
        "count": 1
      }]
    }
  }
}
```

### Azure Portal Setup
1. Create Log Analytics Workspace
2. Create custom metric definition
3. Build dashboard with:
   - Disk usage over time (line chart)
   - Cleanup frequency (bar chart)
   - Space freed (pie chart)
4. Configure alert rules

---

## Challenge 8: Slack/Teams Notifications ⭐

**Difficulty:** Easy
**Time:** 15-20 minutes

### Goal
Send rich notifications to Slack or Teams after cleanup.

### Requirements
- Include: disk usage before/after, space freed, path cleaned
- Add emoji indicators (✅ success, ⚠️ warning, ❌ error)
- Format nicely with markdown

### Implementation Hint

**Slack Webhook:**
```javascript
// HTTP Request node
POST https://hooks.slack.com/services/YOUR/WEBHOOK/URL

Body:
{
  "text": "Disk Space Cleanup Report",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*✅ Disk Cleanup Complete*\n\n*Before:* {{ $json.usage_before }}%\n*After:* {{ $json.usage_after }}%\n*Freed:* ~{{ $json.space_freed }}%\n*Path:* `{{ $json.cleanup_path }}`"
      }
    }
  ]
}
```

**Teams Webhook:**
```javascript
POST https://outlook.office.com/webhook/YOUR/WEBHOOK/URL

Body:
{
  "@type": "MessageCard",
  "@context": "http://schema.org/extensions",
  "summary": "Disk Cleanup Complete",
  "themeColor": "0078D7",
  "title": "✅ Disk Space Cleanup",
  "sections": [{
    "facts": [
      {"name": "Before:", "value": "{{ $json.usage_before }}%"},
      {"name": "After:", "value": "{{ $json.usage_after }}%"},
      {"name": "Freed:", "value": "~{{ $json.space_freed }}%"},
      {"name": "Path:", "value": "{{ $json.cleanup_path }}"}
    ]
  }]
}
```

---

## Challenge 9: Human Approval Workflow ⭐⭐⭐

**Difficulty:** Hard
**Time:** 45-60 minutes

### Goal
Require human approval before executing cleanup in production.

### Requirements
- LLM suggests path
- Send approval request to admin (email/Slack)
- Workflow pauses, waiting for approval
- Execute cleanup only if approved
- Timeout after 1 hour (auto-reject)

### Implementation Hint

**Workflow:**
```
LLM Suggests → Send Approval Request → Wait for Webhook → IF Approved → Execute
```

**Approval Email:**
```
Subject: Disk Cleanup Approval Required

The /tmp directory is at 87% capacity.
AI recommends cleaning: /tmp/logs

Approve: [Click Here - Webhook URL with token]
Reject: [Click Here - Webhook URL with token]

This request expires in 1 hour.
```

**Webhook Receiver:**
```javascript
// In n8n, create separate workflow with Webhook trigger
// URL: /webhook/cleanup-approval/:token

// Validate token
// Store approval decision
// Resume original workflow
```

---

## Challenge 10: Multi-Server Monitoring ⭐⭐⭐⭐

**Difficulty:** Very Hard
**Time:** 60+ minutes

### Goal
Monitor disk space across multiple servers from central n8n instance.

### Requirements
- List of servers to monitor
- SSH to each server to check disk
- Parallel execution for speed
- Aggregate results
- Cleanup highest priority server first

### Implementation Hint

**Server List:**
```javascript
const servers = [
  { hostname: "web-01", ip: "192.168.1.10", priority: 1 },
  { hostname: "app-01", ip: "192.168.1.11", priority: 2 },
  { hostname: "db-01", ip: "192.168.1.12", priority: 3 }
];

return servers.map(s => ({ json: s }));
```

**Check Each Server (Loop):**
```bash
ssh user@{{ $json.ip }} "df -h /tmp | tail -1 | awk '{print \$5}'"
```

**Aggregate & Prioritize:**
```javascript
// Sort by usage (highest first)
// Then by priority (highest first)
// Clean first server over threshold
```

---

## Challenge 11: Predictive Cleanup ⭐⭐⭐⭐

**Difficulty:** Very Hard
**Time:** 90+ minutes

### Goal
Predict when disk will fill and proactively clean before it becomes critical.

### Requirements
- Track disk usage trend over past 7 days
- Calculate growth rate
- Predict when usage will hit 85%
- Trigger cleanup proactively

### Implementation Hint

**Store Historical Data:**
```javascript
// Store in database or JSON file
{
  timestamp: "2026-02-15T10:00:00Z",
  usage_percent: 67
}
```

**Calculate Trend:**
```javascript
// Get last 7 days of data
// Calculate average daily growth rate
// Predict: days_to_85_percent = (85 - current) / daily_growth
// If < 2 days, trigger cleanup now
```

---

## Bonus Challenges

### Extreme: Docker Container Disk Cleanup
Monitor and clean Docker images, containers, and volumes.

### Extreme: S3/Blob Lifecycle Management
Extend to cloud storage with lifecycle policies.

### Extreme: AI-Powered Anomaly Detection
Use LLM to detect unusual disk growth patterns.

### Extreme: Self-Healing Infrastructure
Detect, diagnose, and fix disk issues automatically across entire infrastructure.

---

## Testing Your Extensions

### Unit Testing
- Test each node individually
- Use mock data for LLM responses
- Verify error handling

### Integration Testing
- Test complete workflow end-to-end
- Use test-scenarios.sh to create test conditions
- Verify all branches work

### Production Testing
- Start with low-risk paths (/tmp only)
- Gradually expand scope
- Monitor closely for first week
- Keep manual override ability

---

## Sharing Your Solutions

Built something cool? Share it!

1. Export your workflow (Download as JSON)
2. Add to `/solutions` directory
3. Document what it does
4. Share with your team or community

---

*Return to [Lab Guide](../lab-guide.md) | [README](../README.md)*
