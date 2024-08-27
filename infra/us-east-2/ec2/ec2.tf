variable "instance_type" {
  description = "Instance type for Jenkins EC2"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access to Jenkins EC2"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID where the Jenkins EC2 instance will be deployed"
  type        = string
}

variable "environment" {
  description = "Environment (stage/prod)"
  type        = string
}

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  security_groups = [module.security_groups.jenkins_sg]

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
              EOF

  tags = merge({
    Name = "${var.environment}-jenkins-ec2"
  }, module.tags.tags)
}

resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "${var.environment}-jenkins-instance-profile"
  role = module.iam.jenkins_role
}

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

  tags = merge({
    Name = "${var.environment}-jenkins-sg"
  }, module.tags.tags)
}
