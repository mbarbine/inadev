#!/bin/bash

# Variables
S3_BUCKET="s3://jenkins-backup-bucket"
RESTORE_DIR="/var/lib/jenkins"
LATEST_BACKUP=$(aws s3 ls $S3_BUCKET --recursive | sort | tail -n 1 | awk '{print $4}')

# Download the latest backup from S3
echo "Downloading latest Jenkins backup..."
aws s3 cp s3://$S3_BUCKET/$LATEST_BACKUP /tmp/latest_jenkins_backup.tar.gz

# Extract the backup
echo "Restoring Jenkins backup..."
tar -xzf /tmp/latest_jenkins_backup.tar.gz -C $RESTORE_DIR

# Restart Jenkins to apply the restored configuration
sudo systemctl restart jenkins

echo "Jenkins restored successfully!"
