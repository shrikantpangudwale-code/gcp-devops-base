#!/bin/bash

# Terraform installation
#Have the gnupg, software-properties-common, and curl packages installed
yes | sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl

#Add the HashiCorp GPG key.
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

#Add the official HashiCorp Linux repository.
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

#Update to add the repository, and install the Terraform CLI.
yes | sudo apt-get update && sudo apt-get install terraform

#Install autocomplete packages
sudo terraform -install-autocomplete