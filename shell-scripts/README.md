### Shell Script: `02-startup-script.sh`

This script orchestrates the setup of DevOps tools, Jenkins configuration, SSL certificate provisioning, and reverse proxy setup using NGINX. It sequentially calls other scripts to complete the following tasks:

#### Tools Installed & Configured

- **Java Runtime** – Required to run Jenkins.
- **Jenkins** – Manages CI/CD pipelines.
- **Python** – Executes CbN workflows.
- **Terraform** – Provisions and manages GCP infrastructure.
- **Groovy & Shell Scripts** – Automate Jenkins and Terraform operations.

#### Features

- Install Jenkins
- Auto-create Jenkins admin user via Groovy script
- Install essential DevOps tools (Java, Terraform, Python)
- Configure NGINX as a reverse proxy with HTTPS using Let’s Encrypt
- Integrate DNS configuration using **deSEC**
- Automatically issue SSL certificates via DNS-01 challenge using deSEC API
- Restore Jenkins from backup stored in Google Cloud Storage (GCS)
