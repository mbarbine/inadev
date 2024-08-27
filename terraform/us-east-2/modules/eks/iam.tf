resource "aws_iam_role" "eks_node_role" {
    name = "${var.environment}-eks-node-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Action = "sts:AssumeRole",
            Effect = "Allow",
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        }]
    })

    tags = {
        Name = "${var.environment}-eks-node-role"
    }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_policy" {
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
    role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role" "alb_controller_role" {
    name = "${var.environment}-alb-controller-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Action = "sts:AssumeRole",
            Effect = "Allow",
            Principal = {
                Service = "elasticloadbalancing.amazonaws.com"
            }
        }]
    })

    tags = {
        Name = "${var.environment}-alb-controller-role"
    }
}

resource "aws_iam_role_policy_attachment" "alb_ingress_controller_policy" {
    policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    role       = aws_iam_role.alb_controller_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role       = aws_iam_role.eks_node_role.name
}
