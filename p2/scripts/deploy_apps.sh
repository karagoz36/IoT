#!/bin/bash
set -e

# Add content ConfigMaps
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: app1-content
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
      <title>Application 1</title>
      <style>
        body { background-color: #f0f8ff; font-family: Arial, sans-serif; text-align: center; padding-top: 50px; }
        h1 { color: #0066cc; }
      </style>
    </head>
    <body>
      <h1>Welcome to Application 1</h1>
      <p>This is app1 running on K3s!</p>
      <p>Host: \$(hostname)</p>
    </body>
    </html>
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app2-content
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
      <title>Application 2</title>
      <style>
        body { background-color: #e6ffe6; font-family: Arial, sans-serif; text-align: center; padding-top: 50px; }
        h1 { color: #006600; }
      </style>
    </head>
    <body>
      <h1>Welcome to Application 2</h1>
      <p>This is app2 running on K3s with 3 replicas!</p>
      <p>Pod: \$(hostname)</p>
    </body>
    </html>
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app3-content
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
      <title>Application 3 (Default)</title>
      <style>
        body { background-color: #ffe6e6; font-family: Arial, sans-serif; text-align: center; padding-top: 50px; }
        h1 { color: #cc0000; }
      </style>
    </head>
    <body>
      <h1>Welcome to Application 3</h1>
      <p>This is the default application running on K3s.</p>
      <p>Host: \$(hostname)</p>
    </body>
    </html>
EOF

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