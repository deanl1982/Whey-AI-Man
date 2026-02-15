#!/bin/bash
# ollama-test.sh - Verify Ollama installation and functionality
# Tests: Installation, model download, API responsiveness, disk analysis capability

set -e

echo "=== Ollama Installation Test ==="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Test 1: Check if Ollama is installed
echo "[Test 1/5] Checking if Ollama is installed..."
if command -v ollama &> /dev/null; then
    print_success "Ollama is installed"
    ollama --version
else
    print_error "Ollama is NOT installed"
    echo "Install with: curl -fsSL https://ollama.com/install.sh | sh"
    exit 1
fi
echo ""

# Test 2: Check if Ollama service is running
echo "[Test 2/5] Checking if Ollama service is running..."
if pgrep -x "ollama" > /dev/null; then
    print_success "Ollama service is running"
else
    print_warning "Ollama service not running, attempting to test API anyway..."
fi
echo ""

# Test 3: Check if llama2 model is downloaded
echo "[Test 3/5] Checking for llama2 model..."
if ollama list | grep -q "llama2"; then
    print_success "llama2 model is installed"
    ollama list | grep llama2
else
    print_error "llama2 model NOT found"
    echo "Download with: ollama pull llama2"
    exit 1
fi
echo ""

# Test 4: Test Ollama API with simple prompt
echo "[Test 4/5] Testing Ollama API with simple prompt..."
echo "Sending request to: http://localhost:11434/api/generate"

RESPONSE=$(curl -s http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "Respond with exactly: Ollama is working correctly",
  "stream": false
}')

if echo "$RESPONSE" | grep -q "response"; then
    print_success "Ollama API is responding"
    echo "Response preview:"
    echo "$RESPONSE" | grep -o '"response":"[^"]*"' | head -c 100
    echo "..."
else
    print_error "Ollama API did not respond correctly"
    echo "Response: $RESPONSE"
    exit 1
fi
echo ""

# Test 5: Test disk analysis capability (real scenario)
echo "[Test 5/5] Testing disk analysis capability..."
echo "Simulating disk usage scenario..."

TEST_PROMPT='You are a Linux sysadmin. The /tmp directory is at 87% usage. Here are the largest items:

1.0G    /tmp/logs
50M     /tmp/systemd-private-xxx
12M     /tmp/snap.docker

Based on this, what directory should we clean up? Respond with ONLY the path, nothing else.'

echo ""
echo "Prompt sent:"
echo "$TEST_PROMPT"
echo ""

ANALYSIS_RESPONSE=$(curl -s http://localhost:11434/api/generate -d "{
  \"model\": \"llama2\",
  \"prompt\": \"$TEST_PROMPT\",
  \"stream\": false
}")

if echo "$ANALYSIS_RESPONSE" | grep -q "response"; then
    print_success "Disk analysis test successful"
    echo ""
    echo "AI Response:"
    echo "$ANALYSIS_RESPONSE" | grep -o '"response":"[^"]*"' | sed 's/"response":"//' | sed 's/"$//'
    echo ""

    # Check if response contains reasonable path
    if echo "$ANALYSIS_RESPONSE" | grep -q "/tmp/logs"; then
        print_success "AI correctly identified /tmp/logs as cleanup target"
    else
        print_warning "AI response may need prompt refinement"
    fi
else
    print_error "Disk analysis test failed"
    exit 1
fi
echo ""

# Summary
echo "=============================="
echo "All tests passed! ✅"
echo "=============================="
echo ""
echo "Ollama is ready for the lab!"
echo ""
echo "Quick reference:"
echo "  - API endpoint: http://localhost:11434/api/generate"
echo "  - Model: llama2"
echo "  - Stream mode: false (for easier parsing)"
echo ""
echo "Example curl command:"
echo 'curl http://localhost:11434/api/generate -d '"'"'{'
echo '  "model": "llama2",'
echo '  "prompt": "Your prompt here",'
echo '  "stream": false'
echo '}'"'"
echo ""

exit 0
