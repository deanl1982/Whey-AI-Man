#!/bin/bash
# test-scenarios.sh - Create disk space test scenarios for lab
# Usage: ./test-scenarios.sh [logs|mixed|archives|small|reset]

set -e

show_usage() {
    cat << EOF
Disk Space Cleanup Lab - Test Scenario Creator

Usage: $0 [scenario]

Scenarios:
  logs      - Create large log files (800MB in /tmp/logs)
  mixed     - Create mixed file types (900MB across data/cache/logs)
  archives  - Create old archive files (1GB in /tmp/archives)
  small     - Create thousands of small session files
  reset     - Clean up all test files
  status    - Show current disk usage

Examples:
  $0 logs     # Create log file scenario
  $0 status   # Check disk usage
  $0 reset    # Clean everything up

EOF
}

show_status() {
    echo "=== Current Disk Usage ==="
    df -h /tmp | grep -E '(Filesystem|/tmp)' || df -h /tmp
    echo ""
    echo "=== Space Used by Test Directories ==="
    du -sh /tmp/logs /tmp/data /tmp/cache /tmp/archives /tmp/sessions 2>/dev/null || echo "No test directories found"
}

create_logs() {
    echo "Creating large log files scenario..."
    mkdir -p /tmp/logs

    echo "[1/3] Creating app.log (500MB)..."
    dd if=/dev/zero of=/tmp/logs/app.log bs=1M count=500 status=progress

    echo "[2/3] Creating old.log (300MB)..."
    dd if=/dev/zero of=/tmp/logs/old.log bs=1M count=300 status=progress

    echo "[3/3] Creating archive-2020.log (200MB)..."
    dd if=/dev/zero of=/tmp/logs/archive-2020.log bs=1M count=200 status=progress

    # Set old timestamps
    touch -d "30 days ago" /tmp/logs/old.log
    touch -d "365 days ago" /tmp/logs/archive-2020.log

    echo ""
    echo "✅ Created 1GB of log files in /tmp/logs"
    du -sh /tmp/logs
}

create_mixed() {
    echo "Creating mixed file types scenario..."
    mkdir -p /tmp/{data,cache,logs}

    echo "[1/3] Creating important.db (400MB) in /tmp/data..."
    dd if=/dev/zero of=/tmp/data/important.db bs=1M count=400 status=progress

    echo "[2/3] Creating temp.tmp (300MB) in /tmp/cache..."
    dd if=/dev/zero of=/tmp/cache/temp.tmp bs=1M count=300 status=progress
    touch -d "10 days ago" /tmp/cache/temp.tmp

    echo "[3/3] Creating app.log (200MB) in /tmp/logs..."
    dd if=/dev/zero of=/tmp/logs/app.log bs=1M count=200 status=progress
    touch -d "15 days ago" /tmp/logs/app.log

    echo ""
    echo "✅ Created mixed file types:"
    echo "   - /tmp/data: 400MB (database - should NOT be deleted)"
    echo "   - /tmp/cache: 300MB (temp files - safe to delete)"
    echo "   - /tmp/logs: 200MB (old logs - safe to delete)"
    du -sh /tmp/data /tmp/cache /tmp/logs
}

create_archives() {
    echo "Creating archive files scenario..."
    mkdir -p /tmp/archives

    for i in {1..5}; do
        echo "[$i/5] Creating backup-2020-0$i.tar.gz (200MB)..."
        dd if=/dev/zero of=/tmp/archives/backup-2020-0$i.tar.gz bs=1M count=200 status=none
        touch -d "$((i * 60)) days ago" /tmp/archives/backup-2020-0$i.tar.gz
    done

    echo ""
    echo "✅ Created 1GB of old archive files in /tmp/archives"
    ls -lh /tmp/archives/
}

create_small() {
    echo "Creating many small files scenario..."
    mkdir -p /tmp/sessions

    echo "Creating 10,000 session files..."
    for i in {1..10000}; do
        echo "session_data_$i" > /tmp/sessions/session_$i.txt
        if [ $((i % 1000)) -eq 0 ]; then
            echo "  Created $i files..."
        fi
    done

    # Make them old
    find /tmp/sessions -name "session_*.txt" -exec touch -d "2 days ago" {} \;

    echo ""
    echo "✅ Created 10,000 old session files in /tmp/sessions"
    echo "File count: $(ls /tmp/sessions | wc -l)"
    du -sh /tmp/sessions
}

reset_all() {
    echo "Cleaning up all test files..."

    rm -rf /tmp/logs /tmp/data /tmp/cache /tmp/archives /tmp/sessions

    echo "✅ All test directories removed"
    echo ""
    show_status
}

# Main logic
case "${1:-}" in
    logs)
        create_logs
        echo ""
        show_status
        ;;
    mixed)
        create_mixed
        echo ""
        show_status
        ;;
    archives)
        create_archives
        echo ""
        show_status
        ;;
    small)
        create_small
        echo ""
        show_status
        ;;
    reset)
        reset_all
        ;;
    status)
        show_status
        ;;
    ""|help|-h|--help)
        show_usage
        exit 0
        ;;
    *)
        echo "Error: Unknown scenario '$1'"
        echo ""
        show_usage
        exit 1
        ;;
esac

echo ""
echo "Tip: Run './test-scenarios.sh status' to check disk usage"
echo "Tip: Run './test-scenarios.sh reset' to clean up all test files"
