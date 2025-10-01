#!/bin/bash

source ./scripts/configfile

# Install nginx
sudo apt-get update

yes | sudo apt-get install nginx

# Configure NGINX reverse proxy to Jenkins
sudo tee /etc/nginx/conf.d/${jenkins_subdomain} <<EOF
upstream jenkins {
    server 127.0.0.1:8080;
    keepalive 32;
}

map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}

server {
    listen 80;
    listen [::]:80;
    server_name jenkins.nttd.dedyn.io;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${FQDN};

    ssl_certificate     /etc/letsencrypt/live/jenkins.nttd.dedyn.io/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/jenkins.nttd.dedyn.io/privkey.pem;

    # Simple, safe TLS baseline
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    access_log /var/log/nginx/jenkins.access.log;
    error_log  /var/log/nginx/jenkins.error.log;

    # Single proxy location
    location / {
        proxy_pass http://jenkins;
        proxy_http_version 1.1;
        proxy_redirect off;

        # WebSocket + headers Jenkins expects
        proxy_set_header Host               $host;
        proxy_set_header X-Real-IP          $remote_addr;
        proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto  $scheme;
        proxy_set_header X-Forwarded-Host   $host;
        proxy_set_header X-Forwarded-Port   $server_port;

        proxy_set_header Upgrade            $http_upgrade;
        proxy_set_header Connection         $connection_upgrade;

        proxy_buffering off;
        proxy_request_buffering off;

        proxy_connect_timeout  90s;
        proxy_send_timeout     600s;
        proxy_read_timeout     600s;
    }
}

EOF

# udpate nginx conf.d
sudo rm /etc/nginx/nginx.conf

sudo tee /etc/nginx/nginx.conf <<EOF
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 768;
    # multi_accept on;
}

http {
    ##
    # Basic Settings
    ##

    sendfile on;
    tcp_nopush on;
    types_hash_max_size 2048;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ##
    # SSL Settings
    ##

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
    ssl_prefer_server_ciphers on;

    ##
    # Logging Settings
    ##

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    ##
    # Gzip Settings
    ##

    gzip on;

    include /etc/nginx/conf.d/*.conf;
}
EOF

sudo nginx -t && sudo systemctl reload nginx

echo "NGINX is set up as reverse proxy for ${jenkins_subdomain} at https://${FQDN}"
### ----------------------------------