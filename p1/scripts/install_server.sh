#!/bin/bash

# Update the system
apt-get update -y
apt-get upgrade -y

# Install required packages
apt-get install -y curl wget vim net-tools

# Disable swap (required for Kubernetes)
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Install K3s server
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} sh -s - --node-ip=${SERVER_IP} --bind-address=${SERVER_IP} --advertise-address=${SERVER_IP} --write-kubeconfig-mode=644


# Wait for K3s to start
sleep 10

# Get the node token and save it to a file that can be shared with the worker node
sudo cat /var/lib/rancher/k3s/server/node-token > ${NODE_TOKEN_FILE}
chmod 644 ${NODE_TOKEN_FILE}

# Configure kubectl for the vagrant user
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sed -i "s/127.0.0.1/${SERVER_IP}/g" /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

echo "K3s server has been installed successfully!"
echo "You can connect to the server with: vagrant ssh ${HOSTNAME}"
echo "Use kubectl to interact with Kubernetes"