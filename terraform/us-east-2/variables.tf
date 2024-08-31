variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "eks_instance_type" {
  description = "The EC2 instance type for the EKS worker nodes."
  type        = string
}

variable "eks_desired_capacity" {
  description = "The desired number of EKS worker nodes."
  type        = number
}

variable "eks_max_capacity" {
  description = "The maximum number of EKS worker nodes."
  type        = number
}

variable "eks_min_capacity" {
  description = "The minimum number of EKS worker nodes."
  type        = number
}

variable "alb_health_check_path" {
  description = "The health check path for the ALB."
  type        = string
}

variable "environment" {
  description = "The environment being deployed (stage or prod)."
  type        = string
}

variable "jenkins_instance_type" {
  description = "The instance type for Jenkins EC2."
  type        = string
}

variable "key_name" {
  description = "The name of the SSH key to use for EC2 and EKS instances."
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "availability_zones" {
  description = "The availability zones to deploy the resources in."
  type        = list(string)
}

variable "nat_gateway_id" {
  description = "The ID of the NAT Gateway."
  type        = string
}

variable "ecr_repo_uri" {
  description = "The URI of the ECR repository."
  type        = string
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for Jenkins backups."
  type        = string
}

variable "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  type        = string
}

variable "jenkins_iam_role_arn" {
  description = "The ARN of the IAM role for Jenkins."
  type        = string
}

variable "eks_iam_role_arn" {
  description = "The ARN of the IAM role for EKS."
  type        = string
}

variable "domain_name_1" {
  description = "The primary domain name."
  type        = string
}

variable "domain_name_2" {
  description = "The secondary domain name."
  type        = string
}

variable "domain_name_dev" {
  description = "The development domain name."
  type        = string
}

variable "jenkins_port" {
  description = "The port on which Jenkins will be accessible."
  type        = number
}

variable "backup_dir" {
  description = "The directory where Jenkins backups will be stored."
  type        = string
}

variable "jenkins_volume" {
  description = "The volume name for Jenkins data storage."
  type        = string
}

variable "jenkins_volume_size" {
  description = "The size of the Jenkins data volume in GB."
  type        = number
}

variable "jenkins_backup_bucket" {
  description = "The S3 bucket name for Jenkins backups."
  type        = string
}

variable "jenkins_backup_lifecycle" {
  description = "The lifecycle policy for Jenkins backups in S3."
  type        = number
}

variable "jenkins_backup_schedule" {
  description = "The schedule for Jenkins backups."
  type        = string
}

variable "jenkins_backup_retention" {
  description = "The retention period for Jenkins backups."
  type        = number
}

variable "jenkins_backup_image" {
  description = "The Docker image for Jenkins backup."
  type        = string
}

variable "jenkins_backup_port" {
  description = "The port for the Jenkins backup service."
  type        = number
}

variable "jenkins_backup_volume" {
  description = "The volume name for Jenkins backup data."
  type        = string
}

variable "jenkins_backup_volume_size" {
  description = "The size of the Jenkins backup data volume in GB."
  type        = number
}
