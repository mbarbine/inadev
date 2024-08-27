provider "aws" {
  region = var.region
}

# VPC Setup
module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  environment = var.environment
}

module "eks" {
  source = "./modules/eks"
}

# ALB Ingress Controller Setup
module "alb_ingress_controller" {
  source = "./modules/alb"
}

# EC2 Setup
module "ec2" {
  source = "./modules/ec2"
  environment = var.environment
  key_name = var.key_name
  jenkins_instance_type = var.jenkins_instance_type
}

module "ec2_jenkins" {
  source = "./modules/ec2"
  environment = var.environment
  key_name = var.key_name
  jenkins_instance_type = var.jenkins_instance_type
}

# Key Pair Setup
module "key_pairs" {
  source = "./modules/key-pairs"
}

# Root module to define EKS, EC2, VPC, IAM, ALB, and other services
module "iam" {
  source = "./modules/iam"
}

module "security_groups" {
  source = "./modules/security_groups"
}

module "logging" {
  source = "./modules/logging"
  s3_bucket_name = var.s3_bucket_name
  cloudwatch_log_group_name = var.cloudwatch_log_group_name
  eks_cluster_name = module.eks.cluster_name
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "jenkins_public_ip" {
  value = module.ec2.jenkins_public_ip
}
