#!/bin/bash
set -e

# Update system and install dependencies
sudo apt-get update -y
sudo apt-get install -y curl

# Install K3s with specific IP configuration
export SERVER_IP="192.168.56.110"
curl -sfL https://get.k3s.io | sudo sh -s - \
  --node-ip=${SERVER_IP} \
  --bind-address=${SERVER_IP} \
  --advertise-address=${SERVER_IP}

# Wait for K3s to start
echo "Waiting for K3s to initialize..."
sleep 30

# Allow kubectl access
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo sed -i "s/127.0.0.1/${SERVER_IP}/g" $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Verify installation
kubectl get nodes

# Add /etc/hosts entry
echo "192.168.56.110  app1.com app2.com app3.com" | sudo tee -a /etc/hosts > /dev/null