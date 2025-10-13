#!/bin/bash

export script_dir="scripts"

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
git clone "${github_url_with_auth}" "${script_dir}"

### ----------------------------------
source ./${script_dir}/configfile

echo "Installing Jenkins and DevOps tools..."
bash ./${script_dir}/shell-scripts/02-install-jenkins.sh ${script_dir}

echo "Setting up SSL via Let's Encrypt (deSEC)..."
bash ./${script_dir}/shell-scripts/03-get-ssl-certificate.sh ${script_dir}

echo "Configuring NGINX as reverse proxy..."
bash ./${script_dir}/shell-scripts/04-install-configure-nginx.sh ${script_dir}

echo "Installing terraform..."
bash ./${script_dir}/shell-scripts/05-install-terraform.sh

echo "Setup complete. Access Jenkins at: https://${jenkins_subdomain}.${domain}"

### ----------------------------------
