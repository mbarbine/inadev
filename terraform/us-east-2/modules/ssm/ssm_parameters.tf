resource "aws_ssm_parameter" "jenkins_admin_password" {
  name        = "/${var.environment}/jenkins/admin_password"
  description = "Jenkins Admin Password"
  type        = "SecureString"
  value       = var.jenkins_admin_password
  tags = merge(
    {
      Name = "${var.environment}-jenkins-password"
    },
    module.tags.tags
  )
}

resource "aws_ssm_parameter" "jenkins_api_token" {
  name        = "/${var.environment}/jenkins/api_token"
  description = "Jenkins API Token"
  type        = "SecureString"
  value       = var.jenkins_api_token
  tags = merge(
    {
      Name = "${var.environment}-jenkins-token"
    },
    module.tags.tags
  )
}
