#!/bin/bash
set -e

JENKINS_HOME="/var/lib/jenkins"
GROOVY_SRC="./${1}/groovy-scripts"

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

sleep 60

echo "Disabling setup wizard"
sudo bash -c "echo 2.0 > ${JENKINS_HOME}/jenkins.install.UpgradeWizard.state"
sudo bash -c "echo 2.0 > ${JENKINS_HOME}/jenkins.install.InstallUtil.lastExecVersion"
sudo chown jenkins:jenkins ${JENKINS_HOME}/jenkins.install.*

# Place init.groovy.d
sudo mkdir -p ${JENKINS_HOME}/init.groovy.d/
for script in ${GROOVY_SRC}/*.groovy; do
  sudo cp "${script}" ${JENKINS_HOME}/init.groovy.d/
done

sudo chown -R jenkins:jenkins ${JENKINS_HOME}/init.groovy.d/

# Enable Jenkins
echo "Enabling and starting Jenkins"
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "Jenkins installation and configuration complete."
