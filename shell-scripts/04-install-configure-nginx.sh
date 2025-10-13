#!/bin/bash

# Load configuration variables
source ./${1}/configfile
export FQDN="${jenkins_subdomain}.${domain}"

# Sanity checks for required vars
if [[ -z "${jenkins_subdomain}" || -z "${FQDN}" ]]; then
    echo "Error: ${jenkins_subdomain} or ${FQDN} not set in configfile"
    exit 1
fi

sudo apt update
sudo apt install -y nginx 

# Backup default nginx config
if [ -f /etc/nginx/nginx.conf ]; then
    sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup.$(date +%s)
fi

# Write new nginx.conf
sudo tee /etc/nginx/nginx.conf > /dev/null <<EOF
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 768;
}

http {
    sendfile on;
    tcp_nopush on;
    types_hash_max_size 2048;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Secure SSL config
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    gzip on;

    include /etc/nginx/conf.d/*.conf;
}
EOF

# Create Jenkins NGINX reverse proxy configuration
sudo tee /etc/nginx/conf.d/${jenkins_subdomain}.conf > /dev/null <<EOF
upstream jenkins {
    server 127.0.0.1:8080;
    keepalive 32;
}

map \$http_upgrade \$connection_upgrade {
    default upgrade;
    ''      close;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name ${FQDN};
    return 301 https://\$host\$request_uri;
}

# HTTPS reverse proxy to Jenkins
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${FQDN};

    ssl_certificate     /etc/letsencrypt/live/${FQDN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${FQDN}/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    access_log /var/log/nginx/jenkins.access.log;
    error_log  /var/log/nginx/jenkins.error.log;

    location / {
        proxy_pass http://jenkins;
        proxy_http_version 1.1;
        proxy_redirect off;

        proxy_set_header Host               \$host;
        proxy_set_header X-Real-IP          \$remote_addr;
        proxy_set_header X-Forwarded-For    \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto  \$scheme;
        proxy_set_header X-Forwarded-Host   \$host;
        proxy_set_header X-Forwarded-Port   \$server_port;

        proxy_set_header Upgrade            \$http_upgrade;
        proxy_set_header Connection         \$connection_upgrade;

        proxy_buffering off;
        proxy_request_buffering off;

        proxy_connect_timeout  90s;
        proxy_send_timeout     600s;
        proxy_read_timeout     600s;
    }
}
EOF

# Test and reload NGINX
sudo nginx -t
if [[ $? -ne 0 ]]; then
    echo "NGINX configuration test failed. Aborting."
    exit 1
fi

# Obtain SSL cert using Certbot if it doesn't exist
if [ ! -f /etc/letsencrypt/live/${FQDN}/fullchain.pem ]; then
    echo "SSL certificate not found for ${FQDN}..."
    exit 1
else
    echo "SSL certificate already exists for ${FQDN}"
fi

# Reload nginx with new certs
sudo systemctl restart nginx
sudo systemctl restart jenkins

echo "NGINX is set up as a reverse proxy for Jenkins at https://${FQDN}"
