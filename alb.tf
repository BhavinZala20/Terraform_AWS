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
    from_port   = var.alb_sg_from_port
    to_port     = var.alb_sg_to_port
    protocol    = var.alg_sg_protocol
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
  port              = var.alb_listener_port
  protocol          = var.alb_listener_protocol

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
  port                 = var.alb_target_group_port
  protocol             = var.alb_target_group_protocol
  vpc_id               = aws_vpc.main.id
  deregistration_delay = var.alb_dereg_delay
  target_type          = var.alb_target_type

  health_check {
    path                = "/"
    healthy_threshold   = var.ec2_alb_healthy_threshold
    unhealthy_threshold = var.ec2_alb_unhealthy_threshold
    interval            = var.ec2_health_check_interval
    port                = "traffic-port"
    protocol            = var.ec2_health_check_protocol
    timeout             = var.ec2_health_check_timeout
  }
  depends_on = [aws_alb.alb]
  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

# # Attach EC2 with Target Group
# resource "aws_alb_target_group_attachment" "main" {
#   target_group_arn = aws_alb_target_group.ec2_target.arn
#   target_id        = aws_instance.ecs_instance.id
# }

resource "aws_autoscaling_attachment" "ec2_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  lb_target_group_arn    = aws_alb_target_group.ec2_target.arn
}

# Target Group for FARGATE Launch Type
resource "aws_alb_target_group" "fargate_target" {
  name                 = "alb-fargate"
  port                 = var.fargate_tg_port
  protocol             = var.fargate_tg_protocol
  vpc_id               = aws_vpc.main.id
  target_type          = var.fargate_tg_targate_type
  deregistration_delay = var.fargate_tg_dereg_delay

  health_check {
    path                = "/"
    healthy_threshold   = var.fargate_health_check_healthy_threshold
    unhealthy_threshold = var.fargate_health_check_unhealthy_threshold
    interval            = var.fargate_health_check_interval
    timeout             = var.fargate_health_check_timeout
    port                = "traffic-port"
    protocol            = var.fargate_health_check_protocol
  }
  depends_on = [aws_alb.alb]
  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

