# Frontend Application Load Balancer

# ALB Security Group
resource "aws_security_group" "David_Sol_alb_security_group" {
  name        = "David_Sol_alb_security_group"
  description = "Allows ingress from internet, egress to instances"
  vpc_id      = aws_vpc.David_Sol_vpc.id
  # Allow access port 80
  ingress {
    description = "Public HTTP"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow to connect to destination instances
  egress {
    description     = "Destination Auto Scaling Group"
    protocol        = "tcp"
    from_port       = 8000
    to_port         = 8000
    security_groups = [aws_security_group.David_Sol_frontend_security_group.id]
  }
  tags = {
    Name = "David_Sol_alb_security_group"
  }
}

# Public Application Load Balancer
resource "aws_lb" "David_Sol_alb" {
  name                       = "David-Sol-alb"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = aws_subnet.David_Sol_public_subnets.*.id
  security_groups            = [aws_security_group.David_Sol_alb_security_group.id]
  enable_deletion_protection = false

  tags = {
    Name = "David_Sol_alb"
  }
}

# Target Group for the Autoscaling Group
resource "aws_lb_target_group" "David_Sol_target_group" {
  name     = "David-Sol-target-group"
  protocol = "HTTP"
  port     = 8000
  vpc_id   = aws_vpc.David_Sol_vpc.id

  health_check {
    enabled  = true
    protocol = "HTTP"
    port     = 8000
    path     = "/_health"
    matcher  = "200"
  }
}

# Listener for port 80 redirecting to Autoscaling group 8000
resource "aws_lb_listener" "David_Sol_alb_listener" {
  load_balancer_arn = aws_lb.David_Sol_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.David_Sol_target_group.arn
  }
}