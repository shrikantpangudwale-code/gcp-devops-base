# Creates GCP Resources

1. Terraform Script: `main.tf`
	The `main.tf` script provisions the following resources in GCP:
	- Service Account
		- Name: `devops@<gcp-project-id>.iam.gserviceaccount.com`
		- Assigned Roles:
		  - `roles/iam.serviceAccountUser`
		  - `roles/compute.admin`
		  - `roles/appengine.admin`
		  - `roles/storage.admin`
		  - `roles/cloudbuild.builds.editor`
	- Network Infrastructure
		- VPC Network: `devops-network`
		- Subnet: `devops-subnetwork`
		- Firewall Rules: `devops-firewall`
		  - Allows TCP Ports: `["22", "443", "80", "8080", "3000"]`
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
		- Startup Script: `02-startup-script.sh`
		- Shutdown Script: `08-jenkins-backup.sh`
	- (Optional) DNS Records
		- Jenkins Domain: `jenkins.nttd.dedyn.io`
		- Enables external access to Jenkins on port `8080`.
