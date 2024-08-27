resource "aws_s3_bucket" "jenkins_backup" {
  bucket = "${var.environment}-jenkins-backup"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.kms_key_id  # Specify your KMS Key here
      }
    }
  }

  tags = {
    Name        = "${var.environment}-jenkins-backup"
    Environment = var.environment
  }
}
