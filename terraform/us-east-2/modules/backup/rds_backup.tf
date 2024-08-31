# EBS Volume Snapshot for Jenkins EC2 Instance
resource "aws_ebs_snapshot" "jenkins_backup" {
  volume_id = aws_ebs_volume.jenkins.id
  tags = {
    Name = "${var.environment}-jenkins-backup"
    Environment = var.environment
  }
}

# Automated RDS Backup (future use)
resource "aws_rds_cluster_snapshot" "rds_backup" {
  db_cluster_identifier = aws_rds_cluster.main.id
  db_cluster_snapshot_identifier = "${var.environment}-rds-snapshot"

  tags = {
    Name = "${var.environment}-rds-backup"
  }
}
