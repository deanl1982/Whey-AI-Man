# n8n Nodes Reference

Quick reference for the n8n nodes used in the Disk Space Cleanup Lab.

---

## Schedule Trigger Node

**Purpose:** Automatically run the workflow at regular intervals.

**Common Use Cases:**
- Monitor disk space every 60 seconds
- Check service health every 5 minutes
- Generate reports daily at midnight

**Configuration:**
```
Mode: Every X
Value: 60
Unit: Seconds
```

**Alternatives:**
- **Cron mode:** For specific times (e.g., "0 2 * * *" for 2 AM daily)
- **Interval mode:** Simpler UI for "every X minutes"

**Example Cron Expressions:**
- `*/5 * * * *` - Every 5 minutes
- `0 * * * *` - Every hour
- `0 2 * * *` - Daily at 2 AM
- `0 0 * * 0` - Weekly on Sunday at midnight

**Tips:**
- Start with manual execution (inactive) while building
- Toggle to "Active" when ready for automation
- Use [crontab.guru](https://crontab.guru) to build cron expressions

---

## Execute Command Node

**Purpose:** Run shell commands on the n8n server.

**Common Use Cases:**
- Execute system commands (df, du, find)
- Run scripts
- Interact with CLI tools

**Configuration:**
```
Command: df -h /tmp | tail -1 | awk '{print $5}'
```

**Output:**
Returns stdout, stderr, and exit code:
```json
{
  "stdout": "87%\n",
  "stderr": "",
  "exitCode": 0
}
```

**Important Notes:**
- ⚠️ Commands run with n8n user permissions
- ⚠️ No interactive input supported (use `-y` flags, etc.)
- ⚠️ Timeout default is 120 seconds
- ✅ Can use environment variables
- ✅ Can reference previous node data with expressions

**Expression Example:**
```bash
find {{ $json.cleanup_path }} -type f -mtime +7 -delete
```

**Common Pitfalls:**
- **Quotes:** Command is a single string, be careful with nested quotes
- **Paths:** Use absolute paths, don't rely on working directory
- **sudo:** May not work depending on n8n setup

---

## Code Node

**Purpose:** Run JavaScript to transform, filter, or process data.

**Common Use Cases:**
- Parse command output
- Extract values from strings
- Calculate results
- Format data for next step

**Basic Structure:**
```javascript
// Access input data
const items = $input.all();
const firstItem = $input.first();
const json = firstItem.json;

// Process data
const result = doSomething(json);

// Return output
return [{ json: result }];
```

**Mode Options:**
1. **Run Once for All Items:** Process entire dataset at once (most common)
2. **Run Once for Each Item:** Process items individually (for loops)

**Common Patterns:**

### Parse String to Number
```javascript
const stdout = $json.stdout;
const percent = parseInt(stdout.replace('%', '').trim());
return [{ json: { disk_usage_percent: percent }}];
```

### Format Message
```javascript
const message = `Disk cleanup complete!
Before: ${$json.before}%
After: ${$json.after}%
Freed: ${$json.before - $json.after}%`;

return [{ json: { message }}];
```

### Reference Other Nodes
```javascript
// Get data from node named "IF"
const diskUsage = $('IF').item.json.disk_usage_percent;

// Get data from node at specific index
const prevNodeData = $input.item.json;

return [{ json: { diskUsage }}];
```

**Tips:**
- Use `console.log()` for debugging (appears in execution log)
- Access environment variables: `$env.MY_VAR`
- Handle errors with try/catch
- Return array of objects, even for single item

---

## IF Node

**Purpose:** Branch workflow based on conditions (if/else logic).

**Common Use Cases:**
- Check if disk usage exceeds threshold
- Route based on status codes
- Handle success vs. error paths

**Configuration:**
```
Conditions:
  Value 1: {{ $json.disk_usage_percent }}
  Operation: Larger
  Value 2: 85
```

**Operations:**
- **Number:** Equal, Not Equal, Larger, Larger or Equal, Smaller, Smaller or Equal
- **String:** Contains, Not Contains, Equal, Not Equal, Regex
- **Boolean:** Equal, Not Equal, Exists, Not Exists

**Multiple Conditions:**
- **AND:** All conditions must be true
- **OR:** At least one condition must be true

**Output Paths:**
- **true:** Condition met, continue
- **false:** Condition not met, end or alternate path

**Expression Examples:**
```javascript
// Check percentage
{{ $json.disk_usage_percent > 85 }}

// Check string contains
{{ $json.path.includes('/tmp/logs') }}

// Check exists
{{ $json.cleanup_needed === true }}

// Multiple conditions
{{ $json.usage > 85 && $json.critical === false }}
```

**Tips:**
- Connect both true and false paths for complete workflow
- Use Switch node for 3+ branches
- Test with different values to verify both paths work

---

## HTTP Request Node

**Purpose:** Make HTTP/HTTPS requests to APIs and services.

**Used For:**
- Calling Ollama API for LLM analysis
- Sending notifications to webhooks
- Fetching external data

**Configuration for Ollama:**
```
Method: POST
URL: http://localhost:11434/api/generate
Send Body: Yes
Body Format: JSON
Body:
{
  "model": "llama2",
  "prompt": "{{ $json.my_prompt }}",
  "stream": false
}
```

**Response:**
Returns full HTTP response:
```json
{
  "response": "The answer is /tmp/logs",
  "model": "llama2",
  "done": true
}
```

**Common Options:**
- **Method:** GET, POST, PUT, DELETE, PATCH
- **Authentication:** None, Basic, OAuth, API Key
- **Headers:** Custom headers (e.g., Content-Type)
- **Timeout:** Max wait time for response
- **Redirect:** Follow or don't follow redirects

**Tips:**
- Set `"stream": false` for Ollama to get complete response
- Use expressions to build dynamic URLs/bodies
- Check status code: `{{ $json.$response.status }}`
- Parse JSON response: `{{ $json.response }}`

---

## Set Node

**Purpose:** Create or modify data fields (simpler alternative to Code node).

**Common Use Cases:**
- Rename fields
- Add new fields
- Extract specific values
- Set constants

**Modes:**
1. **Manual Mapping:** Define each field individually
2. **JSON:** Provide entire object as JSON

**Manual Mapping Example:**
```
Field 1:
  Name: disk_usage_percent
  Value: {{ $json.stdout.replace('%', '').trim() }}

Field 2:
  Name: timestamp
  Value: {{ $now }}
```

**Keep Only Set:** Toggle on to remove all other fields.

**Tips:**
- Simpler than Code node for basic transformations
- Can't do complex logic (loops, conditionals)
- Great for renaming or adding timestamps
- Use expressions for dynamic values

---

## Expressions in n8n

**Purpose:** Access and manipulate data from previous nodes.

**Basic Syntax:**
```javascript
{{ $json.fieldName }}          // Current node data
{{ $('NodeName').item.json }}  // Specific node data
{{ $now }}                      // Current timestamp
{{ $env.VAR }}                  // Environment variable
```

**Common Functions:**
```javascript
// String manipulation
{{ $json.text.trim() }}
{{ $json.text.replace('old', 'new') }}
{{ $json.text.toUpperCase() }}
{{ $json.text.split(',') }}

// Number operations
{{ $json.num1 + $json.num2 }}
{{ parseInt($json.strNum) }}
{{ Math.round($json.float) }}

// Date/Time
{{ $now }}                              // Current ISO timestamp
{{ new Date().toISOString() }}          // Also current timestamp
{{ $json.date.toLocaleString() }}      // Format date

// Conditionals
{{ $json.value > 10 ? 'high' : 'low' }}

// Array operations
{{ $json.array[0] }}                   // First element
{{ $json.array.length }}               // Array length
{{ $json.array.join(', ') }}           // Join to string
```

**Reference Previous Nodes:**
```javascript
// By node name
{{ $('Execute Command').item.json.stdout }}

// Current item
{{ $json.fieldName }}

// All items from previous node
{{ $input.all() }}

// First item
{{ $input.first().json }}
```

---

## Webhook Trigger Node

**Alternative Trigger:** Start workflow via HTTP request.

**Use Cases:**
- Trigger from external system
- Integrate with GitHub, Slack, etc.
- Testing workflows manually with curl

**Configuration:**
```
Path: disk-cleanup
Method: POST
Response: Immediately
```

**Test with curl:**
```bash
curl -X POST http://localhost:5678/webhook/disk-cleanup \
  -H "Content-Type: application/json" \
  -d '{"test": true}'
```

---

## Function Node (Advanced)

**Purpose:** More powerful than Code node, can use npm packages.

**When to Use:**
- Need external libraries
- Complex data transformations
- Advanced JavaScript features

**Note:** Not needed for this lab, Code node is sufficient.

---

## Best Practices

### Error Handling
- Add "On Error" connections to handle failures
- Use Try/Catch in Code nodes
- Log errors for debugging

### Node Naming
- Rename nodes for clarity: "Check Disk" not "Execute Command 1"
- Use descriptive names in large workflows
- Helps with expressions: `$('Check Disk')` is clearer

### Testing
- Test each node individually (Execute Node button)
- Use manual trigger while building
- Check output data format at each step

### Performance
- Minimize HTTP requests
- Cache data when possible
- Use Set node instead of Code when simple

---

## Common Workflow Patterns

### Monitor → Alert Pattern
```
[Schedule Trigger] → [Check Condition] → [IF] → [Send Alert]
```

### Fetch → Process → Store Pattern
```
[Schedule] → [HTTP Request] → [Code] → [Database]
```

### Multi-Step Command Pattern
```
[Trigger] → [Command 1] → [Parse] → [Command 2] → [Verify]
```

### Error Handling Pattern
```
[Action] → [IF Success?] → [Notify Success]
                        → [Notify Failure]
```

---

## Debugging Tips

### View Execution Data
1. Run workflow (Execute Workflow button)
2. Click each node to see input/output
3. Check "Execution" tab for full history

### Console Logging
```javascript
// In Code node
console.log("Debug:", $json);
return $input.all();
```

### Test Expressions
- Use Expression Editor (hover over input field)
- Try expressions in Code node first
- Check data structure with `console.log()`

### Common Issues
- **undefined errors:** Check if field exists: `$json.field || 'default'`
- **Node not found:** Check node name spelling
- **Empty output:** Verify previous node has data

---

## Additional Resources

- [n8n Documentation](https://docs.n8n.io)
- [Expression Documentation](https://docs.n8n.io/code-examples/expressions/)
- [Community Forum](https://community.n8n.io)
- [Example Workflows](https://n8n.io/workflows)

---

*Return to [Lab Guide](../lab-guide.md)*
