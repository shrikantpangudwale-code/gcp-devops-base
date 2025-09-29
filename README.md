# gcp-devops-code

Project developed by DevOps Engineers to automate the process of deploying node js application at AppEngine following CI/CD tools and technology on the Google Cloud Platform.
List of tools used in this project are.
1. GCP - Google App Engine, Google Compute Engine, Google Cloud Shell, Google Cloud Storage, Google Cloud DNS
2. Jenkins
3. Terraform
4. Shell script
5. Python
6. Groovy
<p></p>
The basic Structure of project.<p></p><p align=center>
<img width="360" alt="Readme pic" src="https://user-images.githubusercontent.com/106592300/178190993-d9e8056e-3c75-42b6-b347-4f1756b2985f.PNG"></p>
<p></p> <p></p>

This repository includes following directories.
<table align="center">
  <tr>
    <th>1.</th>
    <th> create-vm </th>
    <td> The directory contains terraform script to create required GCP resources like Service-Account, Virtual Network, Subnet, Firewall rules & VM Instance. The shell script installs Java, Jenkins, Terraform, docker, kubectl, etc in VM Instance.</td>
  </tr>
  <tr>
    <th>2.</th>
    <th> create_cluster </th>
    <td> The directory contains terraform script to create kubernetes cluster. It can be triggered from Jenkins. Check directory for more details. </td>
  </tr>
  <tr>
    <th>3.</th>
    <th> deploy_initial_services </th>
    <td> The directory contains terraform script and .yaml file. This deploys the application to the kubernetes cluster. Check directory for more details.</td>
  </tr>
  <tr>
    <th>4.</th>
    <th> devops_shell_scripts </th>
    <td> The directory contains different scipts required to deploy images, validate dns, update region, project from configfile.Check directory for more details.</td>
  </tr>
  <tr>
    <th>5.</th>
    <th> seperate_services_yaml </th>
    <td> The directory contains .yaml for specific services of application. These are useful when you update a certain service in application.</td>
  </tr>
  <tr>
    <th>6.</th>
    <th> configfile </th>
    <td> This file has important variables that you have to change as per your requiremet, like project_name, project_region, cluster_name, dns_zone, service name, etc.</td>
  </tr>
  <tr>
    <th>7.</th>
    <th> jenkins_jobs </th>
    <td>This directory is the third part the project. This directory have the pipeline scripts to Create the cluster, Deploy the services, and Update the services.</td>
  </tr>
</table>

--------------------------------------------------------------------------------------------------------------------------------------------------------------

### Requirements:
1. Google Cloud Platform - Create GCP Project. Enable tools Google Kubernetes Engine, Google Compute Engine, Google Cloud registry, Google Cloud Storage, Google Cloud DNS if required. Also create DNS records(A,SOA, CNAME, NS) if required.
2. The whole project code is available in three repositories i.e.
   - application-services: This repository will have the application microservices with Dockerfile to make containers out of it. Note: check repository for more details [application-services](https://github.com/di-devops-poc/application-services).
   - gcp-devops-code: This repository have the actual scripts to automate the process of deploying application on Kubernetes cluster.Check more details here. [gcp-devops-code](https://github.com/di-devops-poc/gcp-devops-code).
   - jenkins-backup-code: This repository have the scripts to create pipeline jobs in Jenkins. Check repository for more details [here](https://github.com/di-devops-poc/jenkins-backup-code).

### Process:
1. Clone [gcp-devops-code](https://github.com/di-devops-poc/gcp-devops-code) repository in Google cloud shell.
2. Change the directory `cd gcp-devops-code/create-vm/`.
3. Use the code `terraform init`, `terraform plan`, `terraform apply --auto-approve` to run the terraform script.
   - Note: Till now a Virtual Machine, a Virtual Network/ Subnetwork should be created. Tools like Jenkins, Terraform, Kubectl, Docker and Java also have been installed in Virtual Machine. DNS 'A' record also have been updated.(Optional).
4. Access the Jenkins tool on Virtual Machine on port 8080. You can access it directly using domain name if have created DNS record for it.
   - Note: When accessing the Jenkins for the first time...
     - Unlock Jenkins with initialAdminPassword using cmd `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`,
     - Install suggested plugin/Select Plugins to install as per you requirement.
     - Click `skip and continue as admin`. (It is Recommended not to set Username and Password, then you will not have to change the 'import_xml.sh' script from jenkins-backup-code repository.
     - On Instance Configuration Click `Save and Finish` 
     - Click `Start using Jenkins`.
5. SSH into the Virtual Machine.
6. Clone [jenkins-backup-code](https://github.com/di-devops-poc/jenkins-backup-code.git) repository in the Virtual Machine.
7. Change the directory cd jenkins-backup-code/create-jobs-xml.
8. Run the script 'import_xml.sh' to import jobs in Jenkins. Command to run script `bash -x import_xml.sh gcp update_gcp_conf_tf`
9. Voila! you have successfully imported jobs.
   - Note: Change the Jenkins Credentials password in Jenkins if Job fails to clone the repository.
10. You are good to go. Now you just have to start building Job to create Cluster.
--------------------------------------------------------------------------------------------------------------------------------------------------------------
### configfile
Configfile contains different variables that you have to manually update for the first time.
1. gcp_project : GCP Project Name
2. gcp_gcr_project: GCP Project Name. Same as above (Variable used if container images are stored in different project.)
3. gcp_region: GCP project region. e.g. (us-central1) 
4. gcp_zone: GCP project zone. e.g. (us-central1-a)
5. gcp_kubernetes_cluster: Name of Kubernetes Cluster as required.
6. dns_name: DNS name for application. (If set).
7. dns_zone: DNS zone name.
   - Note: You have to manually create the DNS record for your Application External Service. (If required)
--------------------------------------------------------------------------------------------------------------------------------------------------------------
Note : For better understanding check each directory in this repository and other two main repositories.
