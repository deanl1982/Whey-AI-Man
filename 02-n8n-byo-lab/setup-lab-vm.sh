#!/bin/bash
# setup-lab-vm.sh - Complete setup for Disk Space Cleanup Lab
# This is a NEW script, does NOT modify anything in 01-build-n8n/

set -e

echo "=== Disk Space Cleanup Lab Setup ==="
echo "This script will install Docker, n8n, and Ollama with Llama2"
echo ""

# Update system
echo "[1/5] Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker and prerequisites
echo "[2/5] Installing Docker and prerequisites..."
sudo apt install -y docker.io zstd
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Install n8n
echo "[3/5] Installing n8n container..."
sudo docker run -d \
  --name n8n \
  --restart unless-stopped \
  -p 5678:5678 \
  -v n8n_data:/home/node/.n8n \
  -e N8N_SECURE_COOKIE=false \
  n8nio/n8n

# Install Ollama
echo "[4/5] Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

# Pull Llama2 model
echo "[5/5] Downloading Llama2 model (this may take a few minutes, ~4GB)..."
ollama pull llama2

# Verify installations
echo ""
echo "=== Verifying installations ==="
echo "Docker containers:"
docker ps
echo ""
echo "Ollama models:"
ollama list
echo ""

# Create test directory
echo "Setting up test directory..."
mkdir -p /tmp/logs
echo "Test directory created at /tmp/logs"

# Test Ollama
echo ""
echo "Testing Ollama API..."
curl http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "Respond with: Ollama is working",
  "stream": false
}' 2>/dev/null | grep -o "response.*" | head -1

echo ""
echo "=== Setup Complete! ==="
echo "n8n: http://$(hostname -I | awk '{print $1}'):5678"
echo "Ollama: http://localhost:11434"
echo ""
echo "NOTE: You may need to log out and back in for Docker permissions to take effect"
echo "Run 'newgrp docker' to apply Docker group without logging out"
