variable "jenkins_instance_type" {
  description = "Instance type for the Jenkins server"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-0abcdef1234567890"  # Replace with valid AMI for your region
  instance_type = var.jenkins_instance_type
  key_name      = var.key_name
  subnet_id     = element(aws_subnet.public[*].id, 0)
  security_groups = [aws_security_group.jenkins_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo docker run -d -p 8080:8080 -p 50000:50000 --name jenkins \
                  -v /var/jenkins_home:/var/jenkins_home jenkins/jenkins:lts

              # Wait for Jenkins to start
              sleep 60

              # Install Jenkins plugins
              sudo docker exec jenkins bash -c "curl -L http://localhost:8080/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar"
              sudo docker exec jenkins bash -c "java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin git workflow-aggregator docker-workflow -deploy"

              # Create a sample job
              sudo docker exec jenkins bash -c "java -jar jenkins-cli.jar -s http://localhost:8080/ create-job my-sample-job <<EOF
<project>
  <builders>
    <hudson.tasks.Shell>
      <command>echo Hello World</command>
    </hudson.tasks.Shell>
  </builders>
</project>
EOF"
            EOF

  tags = {
    Name = "${var.environment}-jenkins-server"
  }
}
