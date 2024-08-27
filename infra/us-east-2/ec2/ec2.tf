resource "aws_instance" "jenkins_server" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.medium"
  key_name      = "my-key"

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo systemctl start docker
              sudo docker run -d -p 8080:8080 --name jenkins jenkins/jenkins:lts
            EOF

  tags = {
    Name = "JenkinsServer"
  }
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins_server.public_ip
}

