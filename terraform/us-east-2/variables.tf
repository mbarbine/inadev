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
