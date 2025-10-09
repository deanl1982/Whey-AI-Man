#!/bin/bash
set -e

# Update system and install Docker
sudo apt update && sudo apt install -y docker.io
sudo usermod -aG docker $USER

# Create Docker network and volume
docker network create web
docker volume create n8n_data

# Run n8n container
docker run -d --name n8n --restart unless-stopped \
  --network web -p 127.0.0.1:5678:5678 -v n8n_data:/home/node/.n8n \
  -e N8N_HOST=your.domain -e N8N_PROTOCOL=https n8nio/n8n

# Run Nginx container
docker run -d --name nginx --restart unless-stopped \
  --network web -p 80:80 -p 443:443 -v /etc/nginx:/etc/nginx nginx