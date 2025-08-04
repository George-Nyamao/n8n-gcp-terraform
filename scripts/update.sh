#!/bin/bash

docker pull n8nio/n8n
docker stop n8n
docker rm n8n

docker run -d --name n8n \
  -p 5678:5678 \
  -v /root/n8n_data:/home/node/.n8n \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=admin \
  -e N8N_BASIC_AUTH_PASSWORD=changeme \
  -e N8N_HOST=n8n.moraran.com \
  n8nio/n8n
