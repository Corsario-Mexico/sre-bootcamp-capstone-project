# Autoscaling Group

# AutoScaling Group Security Group
# Rules as separate resources to prevent circular dependency
resource "aws_security_group" "David_Sol_frontend_security_group" {
  name        = "David_Sol_frontend_security_group"
  description = "Allows ingress from the ALB, allows egress to the RDS"
  vpc_id      = aws_vpc.David_Sol_vpc.id
  tags = {
    Name = "David_Sol_frontend_security_group"
  }
}

# Frontend instances Ingress rule
resource "aws_security_group_rule" "David_Sol_frontend_security_group_ingress" {
  description              = "HTTP from the Load Balancer on port 8000"
  security_group_id        = aws_security_group.David_Sol_frontend_security_group.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8000
  to_port                  = 8000
  source_security_group_id = aws_security_group.David_Sol_alb_security_group.id
}

# Frontend instances Egress rule, all allowed
resource "aws_security_group_rule" "David_Sol_frontend_security_group_egress" {
  description       = "All Allowed"
  security_group_id = aws_security_group.David_Sol_frontend_security_group.id
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

# Launch Template for FrontEnd instances
resource "aws_launch_template" "David_Sol_launch_template" {
  name                   = "David_Sol_launch_template"
  description            = "Frontend Instances Launch Template"
  image_id               = var.instance_ami
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.David_Sol_frontend_security_group.id]
  instance_market_options {
    market_type = "spot"
  }
  user_data = filebase64("${path.module}/setup_frontend.sh")
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "David_Sol_frontend"
    }
  }
}

resource "aws_autoscaling_group" "David_Sol_autoscaling_group" {
  name                      = "David_Sol_autoscaling_group"
  vpc_zone_identifier       = aws_subnet.David_Sol_private_subnets.*.id
  desired_capacity          = 1
  max_size                  = 4
  min_size                  = 1
  target_group_arns         = [aws_lb_target_group.David_Sol_target_group.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.David_Sol_launch_template.id
    version = "$Latest"
  }
}

# ALB Target Group attachment
# resource "aws_autoscaling_attachment" "David_Sol_ALB_attachment" {
#   autoscaling_group_name = aws_autoscaling_group.David_Sol_autoscaling_group.id
#   alb_target_group_arn   = aws_lb_target_group.David_Sol_target_group.arn
# }
