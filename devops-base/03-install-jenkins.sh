#!/bin/bash
set -e

# Install dependencies
sudo apt update
sudo apt install -y openjdk-21-jre python3 curl unzip gnupg2 software-properties-common python3-venv python3-pip npm

# Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins

# Place init.groovy.d
sudo mkdir -p ${JENKINS_HOME}/init.groovy.d/
sudo cp ./${script_dir}/04-init-jenkins.groovy ${JENKINS_HOME}/init.groovy.d/init.groovy
sudo chown -R jenkins:jenkins ${JENKINS_HOME}/init.groovy.d/

# Enable Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
