module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "${var.environment}-eks-cluster"
  cluster_version = "1.21"
  vpc_id          = aws_vpc.main.id

  node_groups = {
    eks_nodes = {
      desired_capacity = var.eks_desired_capacity
      max_capacity     = var.eks_max_capacity
      min_capacity     = var.eks_min_capacity
      instance_type    = var.eks_instance_type
      key_name         = var.key_name
      # Ensure worker nodes are deployed across multiple AZs
      availability_zones = [element(data.aws_availability_zones.available.names, 0), element(data.aws_availability_zones.available.names, 1)]
    }
  }
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.environment}-node-group"
  node_role_arn   = module.iam.eks_node_role_arn

  scaling_config {
    desired_size = var.eks_desired_capacity
    max_size     = var.eks_max_capacity
    min_size     = var.eks_min_capacity
  }

  instance_types = [var.eks_instance_type]

  subnet_ids = module.vpc.private_subnet_ids

  tags = {
    Name        = "${var.environment}-eks-node-group"
    Environment = var.environment
  }
}

resource "aws_autoscaling_group" "eks_autoscaling_group" {
  min_size            = var.eks_min_capacity
  max_size            = var.eks_max_capacity
  desired_capacity    = var.eks_desired_capacity
  vpc_zone_identifier = module.vpc.private_subnet_ids

  tag {
    key                 = "Name"
    value               = "${var.environment}-eks-autoscaling"
    propagate_at_launch = true
  }

  launch_configuration = aws_launch_configuration.eks_launch_configuration.id
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "environment" {
  description = "Environment (stage/prod)"
  type        = string
}

module "vpc" {
  source = "../vpc"
  # Pass variables from the root module
}

module "iam" {
  source = "../iam"
  # Pass variables from the root module
}

resource "aws_eks_cluster" "eks" {
  name     = var.eks_cluster_name
  role_arn = module.iam.eks_role_arn

  vpc_config {
    subnet_ids = module.vpc.public_subnet_ids
  }

  tags = merge({
    Name = "${var.environment}-eks-cluster"
  }, module.tags.tags)
}
