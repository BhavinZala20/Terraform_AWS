resource "aws_autoscaling_group" "asg" {
  name                 = "AutoScalingGroup"
  desired_capacity     = 1
  min_size             = 0
  max_size             = 2
  termination_policies = ["OldestInstance"]
  # vpc_zone_identifier  = aws_subnet.private.*.id
  vpc_zone_identifier = [
    aws_subnet.private[0].id,
    aws_subnet.private[1].id
  ]

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "template" {
  name = "ec2-lt"

  credit_specification {
    cpu_credits = "standard"
  }

  instance_type          = "t2.micro"
  image_id               = data.aws_ami.ecs.id
  vpc_security_group_ids = [aws_security_group.ecs_tasks.id]
  depends_on             = [aws_nat_gateway.natgw]

  user_data = base64encode(<<-EOF
            #!/bin/bash
            echo "ECS_CLUSTER=Backend_ecs_cluster" >> /etc/ecs/ecs.config
            EOF
  )

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = var.tag_name_for_project
      Environment = var.tag_env_for_project
    }
  }
}

# # EC2 Scale Up
# resource "aws_autoscaling_schedule" "scale_up_ec2_test" {
#   scheduled_action_name  = "scale-up-ec2-test"
#   desired_capacity       = 1
#   min_size               = 1
#   max_size               = 2
#   recurrence             = "30 1 * * *" # 7 AM
#   autoscaling_group_name = aws_autoscaling_group.asg.name
# }

# # scale down
# resource "aws_autoscaling_schedule" "scale_down_ec2_test" {
#   scheduled_action_name  = "scale-down-ec2-test"
#   desired_capacity       = 0
#   min_size               = 0
#   max_size               = 0
#   recurrence             = "30 13 * * *" # 7 PM
#   autoscaling_group_name = aws_autoscaling_group.asg.name
# }

# # EC2 Scale Down - Weekends (keep EC2 instances off)
# resource "aws_autoscaling_schedule" "scale_down_ec2_weekends" {
#   scheduled_action_name  = "scale-down-ec2-weekends"
#   desired_capacity       = 0
#   min_size               = 0
#   max_size               = 0
#   recurrence             = "0 0 * * 6,7" # Saturday and Sunday at midnight
#   autoscaling_group_name = aws_autoscaling_group.asg.name
# }

# # Fargate Auto Scaling Target
# resource "aws_appautoscaling_target" "fargate" {
#   max_capacity       = 2
#   min_capacity       = 0
#   resource_id        = "service/${aws_ecs_cluster.backend_cluster.name}/${aws_ecs_service.fargate_service.name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace  = "ecs"

#   tags = {
#     Name        = var.tag_name_for_project
#     Environment = var.tag_env_for_project
#   }
# }

# # Fargate Scale Up
# resource "aws_appautoscaling_scheduled_action" "fargate_scale_up_test" {
#   name               = "fargate-scale-up-test"
#   service_namespace  = "ecs"
#   resource_id        = aws_appautoscaling_target.fargate.resource_id
#   scalable_dimension = aws_appautoscaling_target.fargate.scalable_dimension
#   schedule           = "cron(30 1 * * ? *)"

#   scalable_target_action {
#     min_capacity = 1
#     max_capacity = 2
#   }
# }

# # Fargate Scale Down 
# resource "aws_appautoscaling_scheduled_action" "fargate_scale_down_test" {
#   name               = "fargate-scale-down-test"
#   service_namespace  = "ecs"
#   resource_id        = aws_appautoscaling_target.fargate.resource_id
#   scalable_dimension = aws_appautoscaling_target.fargate.scalable_dimension
#   schedule           = "cron(30 13 * * ? *)"

#   scalable_target_action {
#     min_capacity = 0
#     max_capacity = 0
#   }
# }

# # Fargate Scale Down - Weekends (keep tasks off)
# resource "aws_appautoscaling_scheduled_action" "fargate_scale_down_weekends" {
#   name               = "fargate-scale-down-weekends"
#   service_namespace  = "ecs"
#   resource_id        = aws_appautoscaling_target.fargate.resource_id
#   scalable_dimension = aws_appautoscaling_target.fargate.scalable_dimension
#   schedule           = "cron(0 0 ? * SAT,SUN *)"

#   scalable_target_action {
#     min_capacity = 0
#     max_capacity = 0
#   }
# }
