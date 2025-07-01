# data "aws_ip_ranges" "cloudfront" {
#   services = ["CLOUDFRONT"]
#   regions  = ["GLOBAL"]
# }

# Security Group for the Application Load Balancer
resource "aws_security_group" "alb" {
  name        = "Security Group for ALB"
  description = "LoadBalancer Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from CloudFront"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # cidr_blocks = data.aws_ip_ranges.cloudfront.cidr_blocks
    # cloudfront incoming traffic
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
  # depends_on         = [aws_ecs_cluster.backend_cluster]
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

# ALB Listener Rule for FARGATE launch type
resource "aws_alb_listener_rule" "fargate_rule" {
  listener_arn = aws_alb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.fargate_target.arn
  }

  condition {
    http_request_method {
      values = ["GET"]
    }
  }

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

# Target Group for EC2 
resource "aws_alb_target_group" "ec2_target" {

  name                 = "alb-ec2"
  port                 = "80"
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main.id
  deregistration_delay = 5
  target_type          = "instance"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 60
    port                = 80
    protocol            = "HTTP"
    timeout             = 30
  }
  depends_on = [aws_alb.alb]
  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }

}

# Attach EC2 with Target Group
resource "aws_alb_target_group_attachment" "main" {
  target_group_arn = aws_alb_target_group.ec2_target.arn
  target_id        = aws_instance.ecs_instance.id
}

# Target Group for FARGATE Launch Type
resource "aws_alb_target_group" "fargate_target" {
  name                 = "alb-fargate"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main.id
  target_type          = "ip"
  deregistration_delay = 5

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 60
    timeout             = 30
    port                = "traffic-port"
    protocol            = "HTTP"
  }
  depends_on = [aws_alb.alb]
  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

