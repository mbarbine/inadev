#!/bin/bash

# Variables
BACKUP_DIR="/var/lib/jenkins"
S3_BUCKET="s3://jenkins-backup-bucket"
TIMESTAMP=$(date +%F_%T)

# Create a compressed backup
echo "Creating Jenkins backup..."
tar -czf /tmp/jenkins_backup_$TIMESTAMP.tar.gz -C $BACKUP_DIR .

# Upload the backup to S3
echo "Uploading backup to S3..."
aws s3 cp /tmp/jenkins_backup_$TIMESTAMP.tar.gz $S3_BUCKET --sse

# Cleanup old backups
find /tmp -name 'jenkins_backup_*.tar.gz' -type f -mtime +7 -exec rm {} \;

echo "Backup completed successfully!"
