#!/bin/bash

export terraform_dir="terraform"

# Source config file
source ./.env
source ../configfile

# Update actual values of variables from config file
sed -i -e "s%GCP_PROJECT%${gcp_project}%g" -e "s%GCP_REGION%${gcp_region}%g" -e "s%GCP_ZONE%${gcp_zone}%g" -e "s%GITHUB_BASE_URL%${github_base_url}%g" -e "s%GITHUB_USER%${github_user}%g" -e "s%GITHUB_CREDS%${github_cred}%g" -e "s%DESEC_API_TOKEN%${DESEC_API_TOKEN}%g" -e "s%DESEC_EMAIL%${DESEC_Email}%g" ./terraform/variables.tf

# Configure terraform backend
# Create GCS bucket
gcloud storage ls gs://${terraform_gcs_name} &> /dev/null || true

# check if GCS exist
if [ $? -ne 0 ]
then
    echo "Bucket gs://${terraform_gcs_name} does not exist. Creating..."
    gcloud storage buckets create gs://${terraform_gcs_name} --project=${gcp_project} --location=${gcp_region}
else
  echo "Bucket gs://${terraform_gcs_name} already exists. Skipping creation."
fi

sed -i "s%GCS_NAME%${terraform_gcs_name}%" ./terraform/provider.tf

# Initialize the terraform
terraform -chdir="${terraform_dir}" init

# Creat GCP resources
terraform -chdir="${terraform_dir}" apply -auto-approve
