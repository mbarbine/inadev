# IAM role for backup automation
resource "aws_iam_role" "backup_role" {
  name = "${var.environment}-backup-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "backup.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${var.environment}-backup-role"
  }
}

resource "aws_iam_policy" "backup_policy" {
  name        = "${var.environment}-backup-policy"
  description = "IAM policy to allow backup operations"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ec2:CreateSnapshot",
        "rds:CreateDBSnapshot"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backup_policy_attachment" {
  policy_arn = aws_iam_policy.backup_policy.arn
  role       = aws_iam_role.backup_role.name
}
