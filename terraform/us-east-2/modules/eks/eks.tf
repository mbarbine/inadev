module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "${var.environment}-eks-cluster"
  cluster_version = "1.21"
  vpc_id          = aws_vpc.main.id
  subnets         = aws_subnet.public[*].id

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
