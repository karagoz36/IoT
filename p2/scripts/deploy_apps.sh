#!/bin/bash
set -e

# Apply application manifests from confs directory
kubectl apply -f /vagrant/confs/app1.yaml
kubectl apply -f /vagrant/confs/app2.yaml
kubectl apply -f /vagrant/confs/app3.yaml
kubectl apply -f /vagrant/confs/ingress.yaml

# Add hosts entry if needed
if ! grep -q "192.168.56.110  app1.com app2.com app3.com" /etc/hosts; then
    echo "192.168.56.110  app1.com app2.com app3.com" | sudo tee -a /etc/hosts > /dev/null
fi

echo "Waiting for applications to be ready..."
kubectl wait --for=condition=available deployment/app1 --timeout=60s
kubectl wait --for=condition=available deployment/app2 --timeout=60s
kubectl wait --for=condition=available deployment/app3 --timeout=60s

echo "Applications deployed successfully!"
echo "Test with:"
echo "curl -H \"Host: app1.com\" http://192.168.56.110"
echo "curl -H \"Host: app2.com\" http://192.168.56.110"
echo "curl http://192.168.56.110 (default app3)"

# Show deployed resources
kubectl get pods
kubectl get services
kubectl get ingress