# VPC CNI Addon
resource "aws_eks_addon" "vpc_cni" {
  cluster_name    = aws_eks_cluster.main.name
  addon_name      = "vpc-cni"
  addon_version   = "v1.9.0-eksbuild.1"

  tags = {
    Name = "${var.environment}-vpc-cni-addon"
  }
}

# CoreDNS Addon
resource "aws_eks_addon" "coredns" {
  cluster_name    = aws_eks_cluster.main.name
  addon_name      = "coredns"
  addon_version   = "v1.8.3-eksbuild.1"

  tags = {
    Name = "${var.environment}-coredns-addon"
  }
}

# Kube-Proxy Addon
resource "aws_eks_addon" "kube_proxy" {
  cluster_name    = aws_eks_cluster.main.name
  addon_name      = "kube-proxy"
  addon_version   = "v1.20.0-eksbuild.1"

  tags = {
    Name = "${var.environment}-kube-proxy-addon"
  }
}
