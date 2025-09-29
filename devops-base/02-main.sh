#!/bin/bash

script_dir="scripts/devops-base"
github_url_with_auth=$(echo "${github-base-url}" | sed -e "s/https:\/\//https:\/\/${github-user}:${github-password}@/")

sudo apt-get update

#Install packages to allow apt to use a repository over HTTPS
sudo apt-get install git

echo "Cloning github repository..."
git clone "${github_url_with_auth}" "scripts"

### ----------------------------------

echo "Installing Jenkins and DevOps tools..."
bash ./${script_dir}/03-install-jenkins.sh

echo "Setting up SSL via Let's Encrypt (deSEC)..."
bash ./${script_dir}/05-get-ssl-certificate.sh

echo "Configuring NGINX as reverse proxy..."
bash ./${script_dir}/06-install-configure-nginx.sh

echo "Installing terraform..."
bash ./${script_dir}/07-install-terraform.sh

echo "Setup complete. Access Jenkins at: https://${jenkins_subdomain}.${domain}"

### ----------------------------------
