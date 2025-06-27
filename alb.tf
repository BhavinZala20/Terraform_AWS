# Security Group for the Application Load Balancer
resource "aws_security_group" "alb" {
  name        = "Security Group for ALB"
  description = "LoadBalancer Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all Outbound Traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application Load Balancer
resource "aws_alb" "alb" {
  name               = "ALB-Prod1"
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.alb.id]

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

# Listner for the ALB
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ec2_target.arn
  }

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

# Target Group for the ALB
resource "aws_alb_target_group" "ec2_target" {

  name                 = "alb-ec2"
  port                 = "80"
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main.id
  deregistration_delay = 5
  target_type          = "instance"

  health_check {
    path                = "/"
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "60"
    port                = "80"
    protocol            = "HTTP"
    timeout             = "30"
  }

  depends_on = [aws_alb.alb]
}

# Attach EC2 with Target Group
resource "aws_alb_target_group_attachment" "main" {
  target_group_arn = aws_alb_target_group.ec2_target.arn
  target_id        = aws_instance.ecs_instance.id
}
