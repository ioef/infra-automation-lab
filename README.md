# Infrastructure Automation Labs

This repository contains small infrastructure and automation examples:

| Directory | Purpose |
| --- | --- |
| [`terraform/`](terraform/) | Provisions the AWS EC2 resources for the Sentry lab. |
| [`ansible/`](ansible/) | Configures the provisioned host and deploys Sentry. |
| [`kubernetes/`](kubernetes/) | Demonstrates application logging and log rotation on Kubernetes. |

## Labs

### Self-hosted Sentry

The Sentry lab combines Terraform and Ansible:

1. Use [`terraform/`](terraform/) to provision an EC2 instance.
2. Use [`ansible/`](ansible/) to install Docker and run Sentry.

Run these steps from the relevant directories as described in their READMEs.
AWS charges apply while resources are running.

### Kubernetes log rotation

The [`kubernetes/`](kubernetes/) lab deploys a sample logger with a shared PVC,
a ConfigMap containing a rotation script, and a CronJob that rotates and
compresses logs.

## Repository layout

```text
.
├── terraform/
├── ansible/
├── kubernetes/
└── README.md
```
