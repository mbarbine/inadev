resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.environment}-cloudwatch-logs"

  tags = {
    Name = "${var.environment}-cloudwatch-log-bucket"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "eks_log_group" {
  name              = "/aws/eks/${var.environment}/logs"
  retention_in_days = 90

  tags = {
    Name = "${var.environment}-eks-log-group"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_stream" "eks_log_stream" {
  name           = "${var.environment}-eks-log-stream"
  log_group_name = aws_cloudwatch_log_group.eks_log_group.name
}
# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "main" {
  name              = "/${var.environment}/infrastructure"
  retention_in_days = 30

  tags = {
    Name = "${var.environment}-cloudwatch-logs"
    Environment = var.environment
  }
}

# Enable VPC Flow Logs
resource "aws_flow_log" "main" {
  log_destination      = aws_cloudwatch_log_group.main.arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
  log_destination_type = "cloud-watch-logs"

  tags = {
    Name = "${var.environment}-vpc-flow-logs"
  }
}

# S3 bucket for application and access logs
resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.environment}-application-logs"

  tags = {
    Name = "${var.environment}-log-bucket"
  }
}

# Enable S3 access logging
resource "aws_s3_bucket_logging" "log" {
  bucket = aws_s3_bucket.main.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "access-logs/"
}
