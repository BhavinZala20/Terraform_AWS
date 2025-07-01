# # resource "aws_launch_template" "ec2_lt" {
# #   image_id      = data.aws_ami.ecs.id
# #   instance_type = "t2.micro"
# # }

# # resource "aws_autoscaling_group" "ec2_asg" {
# #   name                      = "EC2 Auto Scaling"
# #   min_size                  = 1
# #   max_size                  = 2
# #   health_check_grace_period = 300
# #   health_check_type         = "EC2"
# #   desired_capacity          = 2

# #   launch_template {
# #     id      = aws_launch_template.ec2_lt.id
# #     version = "$Latest"
# #   }

# #   lifecycle {
# #     create_before_destroy = true
# #   }

# #   tag {
# #     key                 = "AmazonECSManaged"
# #     value               = true
# #     propagate_at_launch = true
# #   }
# # }

# # Auto Scaling for ECS EC2 Service
# resource "aws_appautoscaling_target" "ecs_ec2_scaling_target" {
#   max_capacity       = 2
#   min_capacity       = 0
#   resource_id        = "service/${aws_ecs_cluster.backend_cluster.name}/${aws_ecs_service.ec2-service.name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace  = "ecs"
# }

# # Schedule to run EC2 service during weekdays 7 AM to 7 PM
# resource "aws_appautoscaling_scheduled_action" "ecs_ec2_scale_up" {
#   name               = "ecs-ec2-weekday-start"
#   service_namespace  = aws_appautoscaling_target.ecs_ec2_scaling_target.service_namespace
#   schedule           = "cron(0 1 ? * MON-FRI *)" # 7 AM IST = 1:30 AM UTC
#   scalable_dimension = aws_appautoscaling_target.ecs_ec2_scaling_target.scalable_dimension
#   resource_id        = aws_appautoscaling_target.ecs_ec2_scaling_target.resource_id

#   scalable_target_action {
#     desired_capacity = 1
#   }
# }

# resource "aws_appautoscaling_scheduled_action" "ecs_ec2_scale_down" {
#   name               = "ecs-ec2-weekday-stop"
#   service_namespace  = aws_appautoscaling_target.ecs_ec2_scaling_target.service_namespace
#   schedule           = "cron(30 13 ? * MON-FRI *)" # 7 PM IST = 1:30 PM UTC
#   scalable_dimension = aws_appautoscaling_target.ecs_ec2_scaling_target.scalable_dimension
#   resource_id        = aws_appautoscaling_target.ecs_ec2_scaling_target.resource_id

#   scalable_target_action {
#     desired_capacity = 0
#   }
# }

# # Auto Scaling for FARGATE Service
# resource "aws_appautoscaling_target" "ecs_fargate_scaling_target" {
#   max_capacity       = 2
#   min_capacity       = 0
#   resource_id        = "service/${aws_ecs_cluster.backend_cluster.name}/${aws_ecs_service.fargate_service.name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace  = "ecs"
# }

# # Schedule to run Fargate service during weekdays 7 AM to 7 PM
# resource "aws_appautoscaling_scheduled_action" "ecs_fargate_scale_up" {
#   name               = "ecs-fargate-weekday-start"
#   service_namespace  = aws_appautoscaling_target.ecs_fargate_scaling_target.service_namespace
#   schedule           = "cron(0 1 ? * MON-FRI *)" # 7 AM IST
#   scalable_dimension = aws_appautoscaling_target.ecs_fargate_scaling_target.scalable_dimension
#   resource_id        = aws_appautoscaling_target.ecs_fargate_scaling_target.resource_id

#   scalable_target_action {
#     desired_capacity = 1
#   }
# }

# resource "aws_appautoscaling_scheduled_action" "ecs_fargate_scale_down" {
#   name               = "ecs-fargate-weekday-stop"
#   service_namespace  = aws_appautoscaling_target.ecs_fargate_scaling_target.service_namespace
#   schedule           = "cron(30 13 ? * MON-FRI *)" # 7 PM IST
#   scalable_dimension = aws_appautoscaling_target.ecs_fargate_scaling_target.scalable_dimension
#   resource_id        = aws_appautoscaling_target.ecs_fargate_scaling_target.resource_id

#   scalable_target_action {
#     desired_capacity = 0
#   }
# }

# # resource "aws_ecs_capacity_provider" "ec2_cp" {
# #   name = "EC2 ASG"

# #   auto_scaling_group_provider {
# #     auto_scaling_group_arn         = aws_autoscaling_group.ec2_asg.arn
# #     managed_termination_protection = "ENABLED"

# #     managed_scaling {
# #       maximum_scaling_step_size = 1000
# #       minimum_scaling_step_size = 1
# #       status                    = "ENABLED"
# #       target_capacity           = 10
# #     }
# #   }
# # }

# # resource "aws_launch_template" "main" {
# #   name          = "Launch Template for EC2"
# #   image_id      = data.aws_ami.ecs.id
# #   instance_type = "t2.micro"

# #   network_interfaces {
# #     associate_public_ip_address = false
# #     security_groups             = aws_security_group.ecs_tasks
# #   }

# #   tag_specifications {
# #     resource_type = "instance"
# #     tags = {
# #       Name        = var.tag_name_for_project
# #       Environment = var.tag_env_for_project
# #     }
# #   }
# # }

# # resource "aws_autoscaling_group" "ec2_asg" {
# #   name                      = "EC2 Auto Scaling Group"
# #   max_size                  = 2
# #   min_size                  = 1
# #   desired_capacity          = 1
# #   health_check_grace_period = 300
# #   #   health_check_type         = "ELB"
# #   availability_zones = var.public_subnet_cidrs

# # }











