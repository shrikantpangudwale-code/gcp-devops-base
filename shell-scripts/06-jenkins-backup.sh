#!/bin/bash

export script_dir="scripts"
source ./${script_dir}/configfile
bkp_file="jenkins-backup-$(date +%F-%H%M).tar.gz"
JENKINS_HOME="/var/lib/jenkins"

# Stop Jenkins (optional but safer)
sudo systemctl stop jenkins

# Create the backup
sudo tar -czf "${bkp_file}" "${JENKINS_HOME}"

#sudo systemctl start jenkins

# Copy to GCS
gsutil cp "${bkp_file}" gs://${jenkins_bkp_gcs}/

### ----------------------------------
