#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Updating the package index..."
sudo apt-get update

echo "Installing prerequisites..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    gnupg

echo "Adding Docker's official GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "Setting up the stable Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Updating the package index again to include Docker packages..."
sudo apt-get update

echo "Installing Docker Engine, CLI, and containerd.io..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo "Verifying Docker installation..."
sudo docker --version

echo "Adding your user to the docker group (optional)..."
sudo usermod -aG docker $USER