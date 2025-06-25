# resource "aws_security_group" "alb" {
#   name        = "Security Group for ALB"
#   description = "LoadBalancer Security Group"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     description = "Allow HTTP"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   #   ingress = {
#   #     description = "Allow HTTPS"
#   #     from_port   = 443
#   #     to_port     = 443
#   #     protocol    = "tcp"
#   #     cidr_block  = ["0.0.0.0/0"]
#   #   }

#   egress {
#     description = "Allow all Outbound Traffic by default"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_alb" "alb" {
#   name               = "ALB-Prod1"
#   load_balancer_type = "application"
#   internal           = false
#   subnets            = [aws_subnet.public[1].id]
#   security_groups    = [aws_security_group.alb.id]
# }

# resource "aws_alb_listener" "http" {
#   load_balancer_arn = aws_alb.alb.arn
#   port              = "80"
#   protocol          = "http"

#   default_action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "OK"
#       status_code  = "200"
#     }
#   }
# }

