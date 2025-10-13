#!/bin/bash

export script_dir="scripts/devops-base"

github_base_url=`curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/github-base-url`
github_user=`curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/github-user`
github_password=`curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/github-password`
export api_token=`curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/api_token`
export email_id=`curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/email_id`

github_url_with_auth=$(echo "${github_base_url}" | sed -e "s/https:\/\//https:\/\/${github_user}:${github_password}@/")

sudo apt-get update

#Install packages to allow apt to use a repository over HTTPS
sudo apt-get install git

echo "Cloning github repository..."
git clone "${github_url_with_auth}" "scripts"

### ----------------------------------
source ./scripts/configfile

echo "Installing Jenkins and DevOps tools..."
bash ./${script_dir}/03-install-jenkins.sh ${script_dir}

echo "Setting up SSL via Let's Encrypt (deSEC)..."
bash ./${script_dir}/05-get-ssl-certificate.sh

echo "Configuring NGINX as reverse proxy..."
bash ./${script_dir}/06-install-configure-nginx.sh

echo "Installing terraform..."
bash ./${script_dir}/07-install-terraform.sh

echo "Setup complete. Access Jenkins at: https://${jenkins_subdomain}.${domain}"

### ----------------------------------
