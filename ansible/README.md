# Ansible

This directory contains the Ansible configuration for provisioning the host
created in `../terraform/` and deploying Sentry.

The playbook installs Docker and Compose, creates a 16 GB swap file, clones
Sentry 26.11.0, runs the installer, and starts the Docker Compose stack.

## Deployment flow

```mermaid
sequenceDiagram
    actor User
    participant Ansible
    participant EC2 as Ubuntu EC2 host
    participant Docker
    participant Sentry

    User->>Ansible: Run playbook
    Ansible->>EC2: Connect over SSH
    Ansible->>EC2: Install base packages
    Ansible->>EC2: Create and enable 16 GB swap
    Ansible->>EC2: Install Docker and Compose
    Ansible->>EC2: Clone Sentry 26.11.0
    Ansible->>EC2: Run Sentry installer
    EC2->>Docker: Start Compose stack
    Docker->>Sentry: Launch services
    User-->>Sentry: Access port 9000
```

## Prerequisites

- Ansible
- The Terraform EC2 instance running
- SSH access using `~/.ssh/id_ed25519`
- Port 22 reachable from the current machine

## Setup

```bash
cd ansible
IP="$(cd ../terraform && terraform output -raw public_ip)"
sed "s/<PUBLIC_IP>/$IP/" inventory.ini.example > inventory.ini
```

Verify SSH and Ansible connectivity:

```bash
ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new "ubuntu@$IP" true
ansible -i inventory.ini sentry -m ping
```

## Run

```bash
ansible-playbook -i inventory.ini playbook.yaml
```

Sentry should be available on the EC2 public address at port `9000`.
