resource "aws_s3_bucket" "jenkins_backups" {
  bucket = "${var.environment}-jenkins-backups"

  tags = merge(
    {
      Name = "${var.environment}-jenkins-backups"
    },
    module.tags.tags
  )
}

resource "aws_s3_bucket_policy" "jenkins_backup_policy" {
  bucket = aws_s3_bucket.jenkins_backups.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = [
            aws_iam_role.jenkins_role.arn
          ]
        },
        Action   = ["s3:PutObject", "s3:GetObject"],
        Resource = "${aws_s3_bucket.jenkins_backups.arn}/*"
      }
    ]
  })
}
