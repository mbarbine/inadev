# Variables for Jenkins EC2 Instance
variable "instance_type" {
  description = "Instance type for Jenkins EC2"
  type        = string
}

variable "jenkins_instance_type" {
  description = "Instance type for the Jenkins server"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "environment" {
  description = "Environment name (stage/prod)"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID where the Jenkins EC2 instance will be deployed"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the Jenkins EC2 instance will be deployed"
  type        = string
}

# Data source to get the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Security Group for Jenkins EC2 Instance
resource "aws_security_group" "jenkins_sg" {
  vpc_id = var.vpc_id

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

  tags = {
    Name = "${var.environment}-jenkins-sg"
  }
}

# IAM Role and Instance Profile for Jenkins EC2
resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "${var.environment}-jenkins-instance-profile"
  role = module.iam.jenkins_role
}

# Jenkins EC2 Instance
resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  security_groups = [aws_security_group.jenkins_sg.id]

  iam_instance_profile = aws_iam_instance_profile.jenkins_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y openjdk-11-jdk
              wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
              sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
              sudo apt-get update
              sudo apt-get install -y jenkins
              sudo systemctl enable jenkins
              sudo systemctl start jenkins

              # Wait for Jenkins to start
              sleep 60

              # Install Jenkins plugins
              sudo wget http://localhost:8080/jnlpJars/jenkins-cli.jar
              sudo java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin git workflow-aggregator docker-workflow -deploy

              # Create a sample job
              sudo java -jar jenkins-cli.jar -s http://localhost:8080/ create-job my-sample-job <<EOF
<project>
  <builders>
    <hudson.tasks.Shell>
      <command>echo Hello World</command>
    </hudson.tasks.Shell>
  </builders>
</project>
EOF
            EOF

  tags = {
    Name = "${var.environment}-jenkins-ec2"
  }
}
