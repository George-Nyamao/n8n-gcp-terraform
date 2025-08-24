#!/bin/bash

# Variables passed from Terraform
DOMAIN="${DOMAIN}"
EMAIL="admin@${DOMAIN}"
N8N_PASSWORD="${N8N_PASSWORD}"
GCS_BUCKET="${GCS_BUCKET}"
SCRIPTS_REPO_URL="${SCRIPTS_REPO_URL}"

# Update and install packages
apt-get update && apt-get upgrade -y
apt-get install -y docker.io nginx certbot python3-certbot-nginx unzip google-cloud-sdk

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Pull latest n8n image and run container
docker run -d --name n8n \
  -p 5678:5678 \
  -v /root/n8n_data:/home/node/.n8n \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=admin \
  -e N8N_BASIC_AUTH_PASSWORD=$N8N_PASSWORD \
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

# Setup scripts
mkdir -p /opt/n8n
curl -o /opt/n8n/backup.sh $SCRIPTS_REPO_URL/scripts/backup.sh
curl -o /opt/n8n/update.sh $SCRIPTS_REPO_URL/scripts/update.sh
chmod +x /opt/n8n/backup.sh
chmod +x /opt/n8n/update.sh

# Inject variables into scripts
sed -i "s|GCS_BUCKET_PLACEHOLDER|$GCS_BUCKET|g" /opt/n8n/backup.sh
sed -i "s|DOMAIN_PLACEHOLDER|$DOMAIN|g" /opt/n8n/update.sh
sed -i "s|N8N_PASSWORD_PLACEHOLDER|$N8N_PASSWORD|g" /opt/n8n/update.sh

# Add cron jobs
(crontab -l 2>/dev/null; echo "0 3 * * * /opt/n8n/backup.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 2 * * * /opt/n8n/update.sh") | crontab -
