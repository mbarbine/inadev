provider "aws" {
  region = var.region
}

# VPC Setup
module "vpc" {
  source = "./modules/vpc"
  cidr_block = var.vpc_cidr
}

# EKS Cluster Setup
module "eks" {
  source = "./modules/eks"
  instance_type    = var.eks_instance_type
  desired_capacity = var.eks_desired_capacity
  max_capacity     = var.eks_max_capacity
  min_capacity     = var.eks_min_capacity
  cluster_name     = var.cluster_name
}

# ALB Ingress Controller Setup
module "alb_ingress_controller" {
  source = "./modules/alb"
  health_check_path = var.alb_health_check_path
}

# Jenkins EC2 Setup
module "ec2_jenkins" {
  source = "./modules/ec2"
  environment = var.environment
}

# Security Groups Setup
module "security_groups" {
  source = "./modules/security_groups"
}

# Key Pair Setup
module "key_pairs" {
  source = "./modules/key-pairs"
}
