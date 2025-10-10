#!/bin/bash                 # Defines this as a bash script
set -e                      # Exits the script if any command fails

# Update system and install Docker
sudo apt update && sudo apt install -y docker.io    # Updates package list and installs Docker
sudo usermod -aG docker $USER                       # Adds current user to docker group for permissions


# Nginx setup
sudo apt install -y nginx           # Installs nginx directly on system
sudo systemctl start nginx         # Starts nginx service
sudo systemctl stop nginx          # Stops nginx service
sudo systemctl enable nginx        # Enables nginx to start on boot
sudo systemctl status nginx        # Checks nginx status
sudo ufw allow 'Nginx Full'        # Allows nginx through firewall
sudo ufw enable                    # Enables firewall
sudo ufw status                    # Checks firewall status


# sudo systemctl restart nginx       # Restarts nginx

sudo docker volume create n8n_data    # Creates a Docker volume to persist n8n data
sudo docker run -d --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n -e N8N_SECURE_COOKIE=false n8nio/n8n # Runs n8n in a Docker container with data persistence