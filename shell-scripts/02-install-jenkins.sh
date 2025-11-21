#!/bin/bash
set -e

script_dir=${1}
source ./${script_dir}/configfile
JENKINS_HOME="/var/lib/jenkins"
jenkins_backup="/var/backups/jenkins"

# Install dependencies
sudo apt update
sudo apt install -y openjdk-21-jre python3 curl unzip gnupg2 software-properties-common python3-venv python3-pip
curl -fsSL https://deb.nodesource.com/setup_25.x | sudo -E bash -
sudo apt install nodejs -y

# Install pandoc, Inkscape
sudo apt install -y \
    pandoc \
    texlive-full \
    graphviz \
    fonts-noto fonts-noto-cjk

pip install pyyaml
npm install -g mermaid-filter

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
for script in ./${script_dir}/groovy-scripts/*.groovy; do
  sudo cp "${script}" ${JENKINS_HOME}/init.groovy.d/
done

sudo chown -R jenkins:jenkins ${JENKINS_HOME}/init.groovy.d/

#Create directory for backup
sudo mkdir -p ${jenkins_backup}
sudo chown -R jenkins:jenkins ${jenkins_backup}

# Enable Jenkins
echo "Enabling and starting Jenkins"
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "Jenkins installation and configuration complete."

# Restore the Jenkins
# List files and get the latest jenkins-backup file
LATEST_FILE=$(gsutil ls gs://${jenkins_bkp_gcs}/jenkins_backup_*.tar.gz | sort | tail -n 1)

if [ -n "${LATEST_FILE}" ]
then
  echo "Found backup: ${LATEST_FILE}"
  sudo systemctl stop jenkins

  gsutil cp "${LATEST_FILE}" ${JENKINS_HOME}
  ARCHIVE_NAME=$(basename "${LATEST_FILE}")
  
  echo "Extracting backup..."
  sudo tar -xzvf "${JENKINS_HOME}/${ARCHIVE_NAME}" -C /
  sudo chown -R jenkins:jenkins ${JENKINS_HOME}
  
  sudo systemctl start jenkins
  echo "Restore of Jenkins completed successfully."
else
  echo "No backup file found in GCS."
fi
