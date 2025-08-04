#!/bin/bash

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_FILE="/tmp/n8n-backup-$TIMESTAMP.tar.gz"

tar -czf $BACKUP_FILE -C /root/n8n_data .

gsutil cp $BACKUP_FILE gs://${project_id}-n8n-backups/
rm -f $BACKUP_FILE
