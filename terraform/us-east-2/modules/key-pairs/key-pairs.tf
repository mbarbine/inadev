resource "aws_key_pair" "jenkins_key" {
  key_name   = "${var.environment}-jenkins-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_key_pair" "eks_key" {
  key_name   = "${var.environment}-eks-key"
  public_key = file("~/.ssh/id_rsa.pub")
}
