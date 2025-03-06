# Inception-of-Things (IoT)

## Summary
This project is a System Administration exercise that aims to deepen your knowledge of Kubernetes by using K3s and K3d with Vagrant. You will learn to set up a personal virtual machine, configure K3s with Ingress, and later implement K3d with Argo CD.

## Project Structure
The project is divided into three mandatory parts and an optional bonus part:

- **Part 1:** K3s and Vagrant
- **Part 2:** K3s and Three Simple Applications
- **Part 3:** K3d and Argo CD
- **Bonus:** Implementing GitLab with Kubernetes

## General Guidelines
- The project must be completed in a virtual machine.
- All configuration files should be placed in structured folders: `p1`, `p2`, `p3`, and `bonus`.
- Understanding K3s and K3d concepts is crucial for completing the project.
- Feel free to explore official documentation and additional resources.

---

## Mandatory Parts

### Part 1: K3s and Vagrant
- Set up two virtual machines using Vagrant.
- Allocate minimal resources (1 CPU, 512MB or 1024MB RAM).
- Configure networking with static IPs:
  - Server: `192.168.56.110`
  - Worker: `192.168.56.111`
- Enable SSH access without a password.
- Install K3s:
  - **Server** runs in controller mode.
  - **Worker** runs in agent mode.
- Install and configure `kubectl`.

### Part 2: K3s and Three Simple Applications
- Deploy a single virtual machine with K3s in server mode.
- Set up three web applications accessible via different HOST entries.
- Configure application routing using Ingress:
  - `app1.com` → Application 1
  - `app2.com` → Application 2 (with 3 replicas)
  - Default → Application 3

### Part 3: K3d and Argo CD
- Install K3d and set up a Kubernetes cluster without Vagrant.
- Create a script to install all necessary dependencies (Docker, K3d, Argo CD, etc.).
- Define two namespaces:
  - `argocd`: for Argo CD
  - `dev`: for an application deployed automatically by Argo CD
- Create a public GitHub repository with deployment configurations.
- Deploy an application with two different versions (`v1`, `v2`) and test version switching using Argo CD.

---

## Bonus Part: GitLab Integration
- Deploy a local GitLab instance inside the cluster.
- Configure GitLab to work with your Kubernetes setup.
- Create a `gitlab` namespace.
- Ensure all features from Part 3 work within GitLab.

---

## Submission and Evaluation
- Submit your work via a Git repository.
- Ensure the directory structure is correctly organized:
  ```
  /p1
    /scripts
    /confs
  /p2
    /scripts
    /confs
  /p3
    /scripts
    /confs
  /bonus (if applicable)
    /scripts
    /confs
  ```
- The project will be evaluated on another machine, so verify compatibility.
- Bonus points are awarded only if the mandatory parts are **perfectly completed**.

---

## Useful Links
- [K3s Documentation](https://k3s.io/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/en/stable/)
- [Vagrant Documentation](https://developer.hashicorp.com/vagrant/docs)

Good luck!
