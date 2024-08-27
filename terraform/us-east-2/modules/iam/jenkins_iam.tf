# Jenkins IAM role and policy
resource "aws_iam_role" "jenkins_role" {
  name = "${var.environment}-jenkins-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.environment}-jenkins-role"
    Environment = var.environment
  }
}

# Jenkins Pipeline IAM Policy
resource "aws_iam_policy" "jenkins_pipeline_policy" {
  name   = "${var.environment}-jenkins-pipeline-policy"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParameterHistory",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:UpdateClusterConfig",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup",
          "eks:CreateUpdate"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the policies to the Jenkins role
resource "aws_iam_role_policy_attachment" "jenkins_pipeline_policy_attachment" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_pipeline_policy.arn
}

# Jenkins IAM Policies for SSM, ECR, S3, EKS
resource "aws_iam_policy" "jenkins_ecr_policy" {
  name   = "${var.environment}-jenkins-ecr-policy"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_ecr_policy_attachment" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_ecr_policy.arn
}

resource "aws_iam_policy" "jenkins_eks_policy" {
  name   = "${var.environment}-jenkins-eks-policy"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:UpdateClusterConfig",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_eks_policy_attachment" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_eks_policy.arn
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

resource "aws_vpc" "main" {
  cidr_block            = var.vpc_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_subnet" {
  count                 = length(var.public_subnet_cidrs)
  vpc_id                = aws_vpc.main.id
  cidr_block            = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet-${count.index}"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_subnet" {
  count      = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.private_subnet_cidrs, count.index)

  tags = {
    Name        = "${var.environment}-private-subnet-${count.index}"
    Environment = var.environment
  }
}
variable "environment" {
  description = "Environment (stage/prod)"
  type        = string
}

variable "ssm_password_parameter" {
  description = "SSM Parameter for Jenkins admin password"
  type        = string
}

resource "aws_iam_role" "jenkins_role" {
  name = "${var.environment}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge({
    Name = "${var.environment}-jenkins-role"
  }, module.tags.tags)
}

resource "aws_iam_policy" "jenkins_policy" {
  name   = "${var.environment}-jenkins-policy"
  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "s3:PutObject",
          "s3:GetObject",
          "cloudwatch:PutMetricData",
          "ec2:DescribeInstances",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource: "*"
      }
    ]
  })

  tags = merge({
    Name = "${var.environment}-jenkins-policy"
  }, module.tags.tags)
}

resource "aws_iam_role_policy_attachment" "jenkins_policy_attachment" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_policy.arn
}

resource "aws_ssm_parameter" "jenkins_admin_password" {
  name        = var.ssm_password_parameter
  type        = "SecureString"
  value       = var.jenkins_admin_password
  description = "Jenkins admin password"

  tags = merge({
    Name = "${var.environment}-jenkins-password"
  }, module.tags.tags)
}
