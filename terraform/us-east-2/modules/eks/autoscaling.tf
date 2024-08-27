resource "aws_autoscaling_group" "eks_autoscaling_group" {
  desired_capacity     = var.eks_desired_capacity
  max_size             = var.eks_max_capacity
  min_size             = var.eks_min_capacity
  vpc_zone_identifier  = aws_subnet.public[*].id
  launch_configuration = aws_launch_configuration.eks_launch_config.id

  tag {
    key                 = "Name"
    value               = "${var.environment}-eks-node"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "eks_launch_config" {
  image_id        = "ami-0abcdef1234567890"  # Replace with a valid AMI ID
  instance_type   = var.eks_instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.eks_sg.id]
}
