#!/bin/bash

DOMAIN="${DOMAIN_PLACEHOLDER}"
EMAIL="admin@${DOMAIN}"  # Use a real admin email for Let's Encrypt

# Update and install packages
apt-get update && apt-get upgrade -y
apt-get install -y docker.io nginx certbot python3-certbot-nginx unzip

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Pull latest n8n image and run container
docker run -d --name n8n \
  -p 5678:5678 \
  -v /root/n8n_data:/home/node/.n8n \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=morara \
  -e N8N_BASIC_AUTH_PASSWORD=m@n3noNane \
  -e N8N_HOST=$DOMAIN \
  n8nio/n8n

# Wait until n8n is accessible
sleep 20

# Set up Nginx reverse proxy config
cat > /etc/nginx/sites-available/n8n <<EOF
server {
  listen 80;
  server_name $DOMAIN;

  location / {
    proxy_pass http://localhost:5678;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_cache_bypass \$http_upgrade;
  }
}
EOF

ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx

# Install SSL certificate
certbot --nginx --non-interactive --agree-tos --email $EMAIL -d $DOMAIN

# Setup backup script
mkdir -p /opt/n8n
curl -o /opt/n8n/backup.sh https://raw.githubusercontent.com/YOUR-GITHUB-REPO/scripts/main/backup.sh
chmod +x /opt/n8n/backup.sh

# Setup update script
curl -o /opt/n8n/update.sh https://raw.githubusercontent.com/YOUR-GITHUB-REPO/scripts/main/update.sh
chmod +x /opt/n8n/update.sh

# Add cron jobs
(crontab -l 2>/dev/null; echo "0 3 * * * /opt/n8n/backup.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 2 * * * /opt/n8n/update.sh") | crontab -
