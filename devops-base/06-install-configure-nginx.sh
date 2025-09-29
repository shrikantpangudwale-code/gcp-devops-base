# Install nginx
sudo apt-get update

yes | sudo apt-get install nginx

FQDN="${jenkins_subdomain}.${domain}"

# Configure NGINX reverse proxy to Jenkins
sudo tee /etc/nginx/sites-available/${jenkins_subdomain} <<EOF
server {
    listen 443 ssl;
    server_name ${FQDN};

    ssl_certificate /etc/letsencrypt/live/jenkins.nttd.dedyn.io/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/jenkins.nttd.dedyn.io/privkey.pem;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Redirect HTTP to HTTPS
    server {
        listen 80;
        server_name ${FQDN};

        return 301 https://\$host\$request_uri;
}
EOF

# Enable site and restart NGINX
sudo ln -sf /etc/nginx/sites-available/${jenkins_subdomain} /etc/nginx/sites-enabled/${jenkins_subdomain}
sudo nginx -t && sudo systemctl reload nginx

echo "NGINX is set up as reverse proxy for ${jenkins_subdomain} at https://${FQDN}"
### ----------------------------------