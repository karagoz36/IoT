#!/bin/bash

# Update the system
apt-get update -y
apt-get upgrade -y

# Install required packages
apt-get install -y curl wget vim net-tools

# Disable swap (required for Kubernetes)
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Wait for the server to be up
echo "Waiting for the server to be ready..."
while ! nc -z ${SERVER_IP} 6443; do
  sleep 1
done
sleep 10

# Wait for the token file to be available
echo "Waiting for node token file..."
while [ ! -f ${NODE_TOKEN_FILE} ]; do
  sleep 1
done

# Read the node token from the file
NODE_TOKEN=$(cat ${NODE_TOKEN_FILE})

# Install K3s agent
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} K3S_URL=https://${SERVER_IP}:6443 K3S_TOKEN=${NODE_TOKEN} sh -s - --node-ip=${WORKER_IP}


echo "K3s agent has been installed successfully!"
echo "You can connect to the worker with: vagrant ssh ${HOSTNAME}"