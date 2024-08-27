resource "aws_cloudwatch_log_group" "jenkins_log_group" {
  name = "/aws/jenkins/${var.environment}/logs"
  retention_in_days = 90

  tags = {
    Name        = "${var.environment}-jenkins-log-group"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_stream" "jenkins_log_stream" {
  name           = "${var.environment}-jenkins-log-stream"
  log_group_name = aws_cloudwatch_log_group.jenkins_log_group.name
}

resource "aws_cloudwatch_log_group" "eks_log_group" {
  name = "/aws/eks/${var.environment}/logs"
  retention_in_days = 90

  tags = {
    Name        = "${var.environment}-eks-log-group"
    Environment = var.environment
  }
}

resource "aws_sns_topic" "alerts_topic" {
  name = "${var.environment}-alerts-topic"

  tags = {
    Name        = "${var.environment}-sns-alerts"
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alerts_topic.arn
  protocol  = "email"
  endpoint  = var.alerts_email  # This should be configured as a variable

  tags = {
    Name        = "${var.environment}-sns-subscription"
    Environment = var.environment
  }
}
resource "aws_sns_topic" "alerts" {
  name = "${var.environment}-alerts"

  tags = merge(
    {
      Name = "${var.environment}-alerts"
    },
    module.tags.tags
  )
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email

  tags = merge(
    {
      Name = "${var.environment}-alerts-subscription"
    },
    module.tags.tags
  )
}
