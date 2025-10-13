#!/bin/bash
set -e

# Load environment variables
source ./scripts/configfile

export FQDN="${jenkins_subdomain}.${domain}"

#Update A record for jenkins subdomain in desec.io
# EXTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)

# curl -X POST "https://desec.io/api/v1/domains/${domain}/rrsets/" \
#   -H "Authorization: Token ${api_token}" \
#   -H "Content-Type: application/json" \
#   -d "{
#         \"subname\": \"${jenkins_subdomain}\",
#         \"type\": \"A\",
#         \"records\": [\"${EXTERNAL_IP}\"],
#         \"ttl\": 3600
#       }"

#sleep 100
### ----------------------------------

# Install Certbot and deSEC plugin
sudo apt install -y certbot python3-pip
sleep 10
sudo pip install certbot-dns-desec

# Create a secure config file to hold deSEC API token.
sudo mkdir -p /etc/letsencrypt
sudo tee /etc/letsencrypt/desec.ini > /dev/null <<EOF
dns_desec_token=${api_token}
EOF
sudo chmod 600 /etc/letsencrypt/desec.ini

# Get certificate
sudo certbot certonly \
  --authenticator dns-desec \
  --dns-desec-credentials /etc/letsencrypt/desec.ini \
  --dns-desec-propagation-seconds 600 \
  -d "${FQDN}" \
  --agree-tos \
  --email "${email_id}" \
  --non-interactive
