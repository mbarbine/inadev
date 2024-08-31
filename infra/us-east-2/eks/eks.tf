# Variables for EKS Cluster and Worker Nodes
variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "environment" {
  description = "Environment (stage/prod)."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the EKS cluster and worker nodes will be deployed."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster."
  type        = list(string)
}

variable "instance_type" {
  description = "The instance type for the EKS worker nodes."
  type        = string
}

variable "desired_capacity" {
  description = "The desired capacity for the EKS worker nodes."
  type        = number
}

variable "min_size" {
  description = "The minimum size of the EKS worker nodes."
  type        = number
}

variable "max_size" {
  description = "The maximum size of the EKS worker nodes."
  type        = number
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  tags = merge({
    Name = "${var.environment}-eks-cluster"
  }, module.tags.tags)
}

# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster" {
  name = "${var.environment}-eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

# EKS Worker Nodes IAM Role
resource "aws_iam_role" "eks_worker_node" {
  name = "${var.environment}-eks-worker-node"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "eks_worker_node" {
  name = "${var.environment}-eks-worker-node"
  role = aws_iam_role.eks_worker_node.name
}

# Attach necessary policies to the worker node IAM role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policies" {
  for_each = {
    "AmazonEKSWorkerNodePolicy"            = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    "AmazonEC2ContainerRegistryReadOnly"   = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    "AmazonEC2ContainerRegistryFullAccess" = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
    "AmazonEKSCNIPolicy"                   = "arn:aws:iam::aws:policy/AmazonEKSCNIPolicy"
  }
  role       = aws_iam_role.eks_worker_node.name
  policy_arn = each.value
}

# Security Group for EKS Worker Nodes
resource "aws_security_group" "eks_worker_node" {
  name_prefix = "${var.environment}-eks-worker-node"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.environment}-eks-worker-node-sg"
  }, module.tags.tags)
}

# Launch Template for EKS Worker Nodes
resource "aws_launch_template" "eks_worker_node" {
  name_prefix           = "${var.environment}-eks-worker-node"
  image_id              = "ami-0c55b159cbfafe1f0"
  instance_type         = var.instance_type
  vpc_security_group_ids = [aws_security_group.eks_worker_node.id]
  
  iam_instance_profile {
    name = aws_iam_instance_profile.eks_worker_node.name
  }

  tags = merge({
    Name = "${var.environment}-eks-worker-node"
  }, module.tags.tags)
}

# Auto Scaling Group for EKS Worker Nodes
resource "aws_autoscaling_group" "eks_worker_node" {
  name_prefix        = "${var.environment}-eks-worker-node"
  desired_capacity   = var.desired_capacity
  min_size           = var.min_size
  max_size           = var.max_size
  launch_template {
    id = aws_launch_template.eks_worker_node.id
  }
  vpc_zone_identifier = var.subnet_ids

  tags = merge({
    Name = "${var.environment}-eks-worker-node-asg"
  }, module.tags.tags)
}
