#!/bin/bash
# setup-lab-vm.sh - Setup for n8n Web Server Health Monitoring Lab
# Installs Docker, n8n, nginx web server, and Ollama with latest llama model

set -e

echo "=== n8n Web Server Health Monitoring Lab Setup ==="
echo "This script will install Docker, n8n, nginx, and Ollama with latest llama model"
echo ""

# Update system
echo "[1/6] Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker and prerequisites
echo "[2/6] Installing Docker and prerequisites..."
sudo apt install -y docker.io zstd
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Install nginx web server
echo "[3/6] Installing nginx web server..."
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Create custom welcome page
echo "[3.5/6] Creating custom welcome page..."
sudo bash -c 'cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Whey-AI-Man</title>
</head>
<body>
    <h1>Welcome to Whey-AI, Man!</h1>
    <p>This is the n8n Web Server Health Monitoring Lab</p>
</body>
</html>
EOF'

echo "Custom welcome page created at http://$(hostname -I | awk '{print $1}')/"

# Install n8n with AI/LangChain support
echo "[4/6] Installing n8n container with AI support..."
sudo docker run -d \
  --name n8n \
  --restart unless-stopped \
  --network host \
  -v n8n_data:/home/node/.n8n \
  -e N8N_SECURE_COOKIE=false \
  -e N8N_HOST=0.0.0.0 \
  -e N8N_PORT=5678 \
  -e N8N_PROTOCOL=http \
  n8nio/n8n:latest

# Install Ollama
echo "[5/6] Installing Ollama..."
echo "Attempting to install Ollama (this may take a moment)..."
if ! curl -fsSL https://ollama.com/install.sh | sh; then
    echo "Warning: Ollama installation script failed. Trying alternative method..."
    # Alternative: Download latest version directly
    OLLAMA_VERSION="0.1.26"
    curl -L https://github.com/ollama/ollama/releases/download/v${OLLAMA_VERSION}/ollama-linux-amd64 -o /tmp/ollama
    sudo install -o root -g root -m 0755 /tmp/ollama /usr/local/bin/ollama

    # Create systemd service
    sudo tee /etc/systemd/system/ollama.service > /dev/null <<EOF
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/usr/local/bin/ollama serve
User=root
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable ollama
    sudo systemctl start ollama

    # Wait for service to be ready
    sleep 5
fi

# Pull latest llama model (llama3.2 is smaller and faster than llama2)
echo "[6/6] Downloading llama3.2 model (this may take a few minutes, ~2GB)..."
ollama pull llama3.2

# Verify installations
echo ""
echo "=== Verifying installations ==="

echo "Docker containers:"
sudo docker ps

echo ""
echo "Ollama models:"
ollama list

echo ""
echo "nginx status:"
sudo systemctl status nginx --no-pager

echo ""
echo "Testing Ollama API..."
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2",
  "prompt": "Respond with: Ollama is working",
  "stream": false
}' 2>/dev/null | grep -o "response.*" | head -1

echo ""
echo "=== Setup Complete! ==="
echo "n8n:    http://$(hostname -I | awk '{print $1}'):5678"
echo "nginx:  http://$(hostname -I | awk '{print $1}')/"
echo "Ollama: http://localhost:11434"
echo ""
echo "NOTE: You may need to log out and back in for Docker permissions to take effect"
echo "Run 'newgrp docker' to apply Docker group without logging out"
echo ""
echo "Next steps:"
echo "1. Access n8n at http://$(hostname -I | awk '{print $1}'):5678"
echo "2. Import the workflow files from n8n-files/ directory"
echo "3. Test by manually stopping nginx: sudo systemctl stop nginx"
