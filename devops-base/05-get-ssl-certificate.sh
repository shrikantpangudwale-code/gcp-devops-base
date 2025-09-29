#!/bin/bash
set -e

# Load environment variables
source ./scripts/devops-base/.env

FQDN="${jenkins_subdomain}.${domain}"

#Update A record for jenkins subdomain in desec.io
EXTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)

curl -X PUT "https://desec.io/api/v1/domains/${domain}/rrsets/${jenkins_subdomain}/A/" \
  -H "Authorization: Token ${DESEC_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
        \"subname\": \"${jenkins_subdomain}\",
        \"type\": \"A\",
        \"records\": [\"${EXTERNAL_IP}\"],
        \"ttl\": 300
      }"

sleep 60
### ----------------------------------

# Install Certbot and deSEC plugin
sudo apt install -y certbot python3-certbot-dns-desec

# Create a secure config file to hold deSEC API token.
sudo mkdir -p /etc/letsencrypt
sudo tee /etc/letsencrypt/desec.ini > /dev/null <<EOF
dns_desec_token = ${DESEC_API_TOKEN}
EOF
sudo chmod 600 /etc/letsencrypt/desec.ini

# Get certificate
sudo certbot certonly \
  --dns-desec \
  --dns-desec-credentials /etc/letsencrypt/desec.ini \
  --dns-desec-propagation-seconds 30 \
  -d "${FQDN}" \
  --agree-tos \
  --email "${DESEC_Email}" \
  --non-interactive
