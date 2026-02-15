# Linux Commands Cheatsheet

Quick reference for disk space management commands used in this lab.

---

## df - Disk Free (Check Disk Usage)

### Basic Usage
```bash
df              # Show disk usage for all filesystems
df -h           # Human-readable (GB, MB instead of bytes)
df -h /tmp      # Show usage for specific filesystem
```

### Example Output
```
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           7.8G  6.8G  1.0G  87% /tmp
```

### Extract Just the Percentage
```bash
df -h /tmp | tail -1 | awk '{print $5}'
# Output: 87%
```

### Extract Numeric Value Only
```bash
df /tmp --output=pcent | tail -1 | tr -d ' %'
# Output: 87
```

### Common Options
- `-h` : Human-readable sizes (1K, 234M, 2G)
- `-T` : Show filesystem type
- `-i` : Show inode usage instead of disk space
- `--output=pcent` : Show only percentage column

---

## du - Disk Usage (Analyze Space)

### Basic Usage
```bash
du /tmp                  # Show size of all items
du -sh /tmp             # Summary: total size only
du -sh /tmp/*           # Size of each item in /tmp
du -ah /tmp | head -20  # All files, top 20
```

### Example Output
```
1.0G    /tmp/logs
400M    /tmp/data
300M    /tmp/cache
50M     /tmp/systemd-private-xxx
```

### Sort by Size (Largest First)
```bash
du -sh /tmp/* | sort -rh
# -r: reverse (largest first)
# -h: human-readable numbers
```

### Top 10 Space Consumers
```bash
du -sh /tmp/* 2>/dev/null | sort -rh | head -10
# 2>/dev/null suppresses permission errors
```

### Common Options
- `-s` : Summary (total only, no subdirectories)
- `-h` : Human-readable sizes
- `-a` : All files (not just directories)
- `-c` : Grand total at the end
- `--max-depth=1` : Don't go into subdirectories

---

## find - Find and Manage Files

### Basic Usage
```bash
find /tmp                    # List all files/dirs
find /tmp -type f            # Only files
find /tmp -type d            # Only directories
```

### Find by Age
```bash
find /tmp -mtime +7          # Modified more than 7 days ago
find /tmp -mtime -7          # Modified less than 7 days ago
find /tmp -mtime 7           # Modified exactly 7 days ago
```

### Find by Size
```bash
find /tmp -size +100M        # Larger than 100MB
find /tmp -size -1M          # Smaller than 1MB
find /tmp -size 50M          # Exactly 50MB
```

### Find by Name/Pattern
```bash
find /tmp -name "*.log"      # All .log files
find /tmp -name "app*"       # Files starting with "app"
find /tmp -iname "*.LOG"     # Case-insensitive
```

### Combine Conditions (AND)
```bash
find /tmp -type f -name "*.log" -mtime +30
# Files ending in .log AND older than 30 days
```

### Combine Conditions (OR)
```bash
find /tmp -name "*.log" -o -name "*.tmp"
# Files ending in .log OR .tmp
```

### Execute Commands on Results
```bash
find /tmp -name "*.log" -mtime +7 -exec ls -lh {} \;
# List details of old log files

find /tmp -name "*.tmp" -exec rm {} \;
# Delete all .tmp files
```

### Delete Files (Safe Method)
```bash
# First, list what will be deleted
find /tmp/logs -type f -mtime +7

# If output looks correct, then delete
find /tmp/logs -type f -mtime +7 -delete
```

### Common Options
- `-type f` : Only files
- `-type d` : Only directories
- `-name` : Match by name
- `-mtime +N` : Modified more than N days ago
- `-size +XM` : Larger than X megabytes
- `-delete` : Delete matching files
- `-exec CMD {} \;` : Execute command on each match

---

## Combining Commands (Used in Lab)

### Check Disk, Get Top Consumers
```bash
echo "Disk usage:"
df -h /tmp

echo ""
echo "Top space consumers:"
du -sh /tmp/* 2>/dev/null | sort -rh | head -10
```

### Find and Count Old Files
```bash
# Count files older than 7 days
find /tmp/logs -type f -mtime +7 | wc -l

# Show their total size
find /tmp/logs -type f -mtime +7 -exec du -ch {} + | tail -1
```

### Before/After Disk Usage
```bash
# Before cleanup
BEFORE=$(df /tmp --output=pcent | tail -1 | tr -d ' %')
echo "Before: ${BEFORE}%"

# Run cleanup
find /tmp/logs -type f -mtime +7 -delete

# After cleanup
AFTER=$(df /tmp --output=pcent | tail -1 | tr -d ' %')
echo "After: ${AFTER}%"
echo "Freed: $((BEFORE - AFTER))%"
```

---

## Advanced Tips

### Redirect Errors
```bash
# Hide "Permission denied" errors
du -sh /tmp/* 2>/dev/null

# Save errors to file
du -sh /tmp/* 2> errors.log

# Send output to file, errors to another
du -sh /tmp/* > output.txt 2> errors.txt
```

### Process Substitution
```bash
# Compare two directory sizes
diff <(du -sh /tmp/logs/*) <(du -sh /var/log/*)
```

### Watch Disk Usage in Real-Time
```bash
watch -n 5 'df -h /tmp | tail -1'
# Updates every 5 seconds
```

### Find Duplicate Files
```bash
find /tmp -type f -exec md5sum {} \; | sort | uniq -w32 -dD
```

---

## Safety Tips

### Always Test First
```bash
# DON'T do this:
# find /tmp -delete  # Too broad!

# DO this instead:
find /tmp -type f -name "*.log" -mtime +30  # List first
find /tmp -type f -name "*.log" -mtime +30 -delete  # Then delete
```

### Use -maxdepth to Limit Scope
```bash
# Only search /tmp, not subdirectories
find /tmp -maxdepth 1 -name "*.log"
```

### Protect Important Paths
```bash
# NEVER run these without careful consideration:
# find / -delete
# rm -rf /
# find /home -delete

# Always specify full paths and conditions
find /tmp/logs -type f -name "*.log" -mtime +30 -delete
```

### Dry Run Pattern
```bash
# Function to preview before delete
preview_delete() {
    echo "Files to be deleted:"
    find "$1" -type f -mtime +7
    echo ""
    read -p "Proceed with deletion? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        find "$1" -type f -mtime +7 -delete
        echo "Deleted!"
    fi
}

# Usage:
preview_delete /tmp/logs
```

---

## Quick Reference Table

| Command | Purpose | Example |
|---------|---------|---------|
| `df -h` | Check disk usage | `df -h /tmp` |
| `du -sh` | Check directory size | `du -sh /tmp/logs` |
| `du -sh *` | Size of each item | `du -sh /tmp/*` |
| `find -mtime +7` | Find old files | `find /tmp -mtime +7` |
| `find -delete` | Delete files | `find /tmp/*.log -delete` |
| `sort -rh` | Sort by size | `du -sh * \| sort -rh` |
| `head -10` | Show first 10 | `du -sh * \| head -10` |
| `tail -1` | Show last line | `df -h \| tail -1` |
| `awk '{print $5}'` | Extract column | `df -h \| awk '{print $5}'` |

---

## n8n Integration Examples

### Execute Command Node - Check Disk
```bash
df -h /tmp | tail -1 | awk '{print $5}'
```

### Execute Command Node - Analyze Space
```bash
du -sh /tmp/* 2>/dev/null | sort -rh | head -10
```

### Execute Command Node - Cleanup
```bash
find /tmp/logs -type f -mtime +7 -delete
```

### Code Node - Parse Output
```javascript
const stdout = $json.stdout;
const percent = parseInt(stdout.replace('%', '').trim());
return [{ json: { disk_usage_percent: percent }}];
```

---

## Related Resources

- [du man page](https://man7.org/linux/man-pages/man1/du.1.html)
- [df man page](https://man7.org/linux/man-pages/man1/df.1.html)
- [find man page](https://man7.org/linux/man-pages/man1/find.1.html)
- [Explainshell.com](https://explainshell.com/) - Explain complex commands

---

*For more examples, see [disk-usage-examples.txt](../sample-data/disk-usage-examples.txt)*
