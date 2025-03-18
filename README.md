# Inception of Things (IoT)

## Project Overview
This project introduces Kubernetes through practical implementation using K3s and K3d. It is divided into three mandatory parts, plus an optional bonus section, focusing on different aspects of container orchestration and deployment.

## Prerequisites
- VirtualBox (or any other VM provider compatible with Vagrant)
- Vagrant
- Git
- Basic knowledge of Linux commands
- Basic understanding of containerization concepts

## Project Structure
```
.
├── p1/                 # Part 1: K3s and Vagrant
│   ├── Vagrantfile     # Virtual machine configuration
│   ├── scripts/        # Installation and setup scripts
│   └── confs/          # Configuration files
├── p2/                 # Part 2: K3s and three simple applications
│   ├── Vagrantfile     # Virtual machine configuration
│   ├── scripts/        # Installation and setup scripts
│   └── confs/          # Application deployment files
├── p3/                 # Part 3: K3d and Argo CD
│   ├── scripts/        # Installation and setup scripts
│   └── confs/          # ArgoCD and application configuration
└── bonus/              # Optional: Gitlab integration
    ├── Vagrantfile     # Virtual machine configuration
    ├── scripts/        # Installation and setup scripts
    └── confs/          # Gitlab and related configuration
```

## Part 1: K3s and Vagrant
This part focuses on setting up a Kubernetes environment with K3s using Vagrant.

### Requirements
- Create two virtual machines with minimal resources (1 CPU, 512MB/1024MB RAM)
- Configure machines with specific hostnames (loginS and loginSW)
- Assign dedicated IPs (192.168.56.110 for Server, 192.168.56.111 for ServerWorker)
- Enable password-less SSH access
- Install K3s in controller mode on the first machine and agent mode on the second

### Implementation
1. Create a Vagrantfile that defines both machines
2. Write installation scripts for K3s (controller and agent)
3. Test the setup by verifying node connectivity

## Part 2: K3s and Three Applications
This part involves deploying three web applications with specific routing rules.

### Requirements
- Set up one virtual machine with K3s in server mode
- Deploy three web applications
- Configure Ingress to route traffic based on HOST headers
- Implement replicas for the second application

### Implementation
1. Create deployment configurations for the three applications
2. Set up Ingress rules for hostname-based routing
3. Configure replicas for the second application
4. Test routing behavior using curl or a web browser

## Part 3: K3d and Argo CD
This part focuses on continuous integration using K3d and Argo CD.

### Requirements
- Install K3d on a virtual machine
- Create two namespaces (ArgoCD and dev)
- Deploy an application with two versions (v1 and v2)
- Configure Argo CD to automatically deploy from a GitHub repository

### Implementation
1. Create installation scripts for K3d and dependencies
2. Set up Argo CD in its dedicated namespace
3. Configure a GitHub repository with application manifests
4. Deploy the application and test version switching

## Bonus: Gitlab Integration
The bonus part extends Part 3 by integrating Gitlab.

### Requirements
- Run Gitlab locally in the cluster
- Configure Gitlab to work with the cluster
- Create a dedicated namespace for Gitlab
- Integrate Gitlab with Argo CD for CI/CD

## Getting Started

### Part 1
```bash
cd p1
vagrant up
```

### Part 2
```bash
cd p2
vagrant up
```

### Part 3
```bash
cd p3
./scripts/install.sh
```

### Testing Part 3
After setup, access Argo CD through the provided URL and verify application deployment.

## Notes
- Ensure all configuration files are properly placed in their respective folders
- Scripts should be executable and well-documented
- All mandatory parts must be completed successfully before the bonus part is evaluated

## Resources
- [K3s Documentation](https://rancher.com/docs/k3s/latest/en/)
- [K3d Documentation](https://k3d.io/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
