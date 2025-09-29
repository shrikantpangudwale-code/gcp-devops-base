# Create GCP Resources

1. Terraform Script: `main.tf`
	The `main.tf` script provisions the following resources in GCP:
	- Service Account
		- Name: `devops@<gcp-project-id>.iam.gserviceaccount.com`
		- Assigned Roles:
		  - `roles/iam.serviceAccountUser`
		  - `roles/compute.admin`
		  - `roles/appengine.admin`
		  - `roles/storage.admin`
		  - `roles/dns.admin`
		  - `roles/dns.admin`
	- Network Infrastructure
		- VPC Network: `devops-network`
		- Subnet: `devops-subnetwork`
		- Firewall Rules: `devops-firewall`
		  - Allows TCP Ports: `["22", "80", "8080", "3000"]`
		  - Allows protocols: `icmp`
	- Virtual Machine Instance
		- Instance Name: `devops-vm`
		- Machine Type: `n2-custom-2-4096`
			- `n2`: series
			- `custom`: machine-type
			- `2`: vCPUs Core
			- `4096`: Memory in MB (4 GB)
		- Boot Disk:
			- Image: `ubuntu-os-cloud/ubuntu-2404-lts`
			- Size: `50` GB
		- Startup Script: `install-devops-tools.sh`
	- (Optional) DNS Records
		- Jenkins Domain: `jenkins.nttd.dedyn.io`
		- Enables external access to Jenkins on port `8080`.

2. Shell Script `install-devops-tools.sh`
	This script installs all the essential DevOps tools on the VM instance:
	- **Java runtime**: Required for running Jenkins.
	- **Jenkins**: Used for creating and managing CI/CD pipelines.
	- **Python**: Executes CbN workflow.
	- **Terraform**: Provisions and manages GCP infrastructure.
	- **Groovy & Shell Scripting**: Facilitates scripting and automation within Jenkins and Terraform workflows.

✅ Install Jenkins
✅ Auto-create admin user via Groovy
✅ Install DevOps tools (Java, Terraform, Python)
✅ Configure NGINX reverse proxy with HTTPS using Let’s Encrypt
✅ Use DNS from deSEC
✅ Automatically get SSL certificate via DNS-01 (deSEC API)