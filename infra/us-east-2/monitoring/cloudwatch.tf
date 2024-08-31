variable "environment" {
  type    = string
  default = "production"  # Provide your desired environment value here
}

variable "alerts_email" {
  type    = string
  default = "example@example.com"  # Provide your email address here
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_jekins" {
  alarm_name          = "${var.environment}-jenkins-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"

  alarm_actions = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.jenkins_instance.id
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_sns_topic" "alerts" {
  name = "${var.environment}-alerts"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alerts_email  # Provide your email address in the variables file
}
resource "aws_cloudwatch_metric_alarm" "jenkins_disk_alarm" {
  alarm_name          = "${var.environment}-jenkins-high-disk-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DiskSpaceUtilization"
  namespace           = "CWAgent"
  dimensions = {
    InstanceId = aws_instance.jenkins.id
    path       = "/"
  }
  threshold           = 80
  period              = 300
  statistic           = "Average"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alerts.arn]

  tags = merge(
    {
      Name = "${var.environment}-jenkins-disk-alarm"
    },
    module.tags.tags
  )
}

resource "aws_cloudwatch_metric_alarm" "jenkins_memory_alarm" {
  alarm_name          = "${var.environment}-jenkins-high-memory-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  dimensions = {
    InstanceId = aws_instance.jenkins.id
  }
  threshold           = 75
  period              = 300
  statistic           = "Average"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alerts.arn]

  tags = merge(
    {
      Name = "${var.environment}-jenkins-memory-alarm"
    },
    module.tags.tags
  )
}
resource "aws_cloudwatch_log_group" "jenkins" {
  name              = "/${var.environment}/jenkins"
  retention_in_days = 30

  tags = merge(
    {
      Name = "${var.environment}-jenkins-cloudwatch-logs"
    },
    module.tags.tags
  )
}

resource "aws_cloudwatch_metric_alarm" "jenkins_cpu_alarm" {
  alarm_name          = "${var.environment}-jenkins-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "This alarm triggers if the Jenkins EC2 instance's CPU utilization exceeds 75% for 10 minutes."
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.jenkins.id
  }

  tags = merge(
    {
      Name = "${var.environment}-jenkins-cpu-alarm"
    },
    module.tags.tags
  )
}
