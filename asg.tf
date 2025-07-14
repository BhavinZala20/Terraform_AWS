resource "aws_autoscaling_group" "asg" {
  name                 = "AutoScalingGroup"
  desired_capacity     = 1
  min_size             = 1
  max_size             = 2
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = aws_subnet.private.*.id

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

  # network_interfaces {
  #   security_groups = [aws_security_group.alb.id]
  # }

  placement {
    availability_zone = var.azs[0]
  }

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

# EC2 Auto Scaling Policy
resource "aws_appautoscaling_target" "ec2" {
  max_capacity       = 2
  min_capacity       = 0
  resource_id        = "service/${aws_ecs_cluster.backend_cluster.name}/${aws_ecs_service.ec2-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

# EC2 Weekday scale up (7 AM UTC)
resource "aws_autoscaling_schedule" "scale_up_ec2_weekdays" {
  scheduled_action_name  = "scale-up-ec2-weekdays"
  desired_capacity       = 1
  min_size               = 1
  max_size               = 2
  recurrence             = "0 7 * * 1-5" # Mon-Fri 7AM UTC
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

# EC2 Weekday scale down (7 PM UTC)
resource "aws_autoscaling_schedule" "scale_down_ec2_weekdays" {
  scheduled_action_name  = "scale-down-ec2-weekdays"
  desired_capacity       = 0
  min_size               = 0
  max_size               = 0
  recurrence             = "0 19 * * 1-5" # Mon-Fri 7PM UTC
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

# EC2 Weekend scale down (Midnight UTC)
resource "aws_autoscaling_schedule" "scale_down_ec2_weekends" {
  scheduled_action_name  = "scale-down-ec2-weekends"
  desired_capacity       = 0
  min_size               = 0
  max_size               = 0
  recurrence             = "0 0 * * 6,7" # Sat, Sun at 00:00 UTC
  autoscaling_group_name = aws_autoscaling_group.asg.name
}


# Weekdays 7 AM: Scale up to 1
resource "aws_appautoscaling_scheduled_action" "scale_up_weekdays" {
  name               = "scale-up-weekdays"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ec2.resource_id
  scalable_dimension = aws_appautoscaling_target.ec2.scalable_dimension
  schedule           = "cron(0 7 ? * MON-FRI *)" # 7 AM UTC weekdays

  scalable_target_action {
    min_capacity = 1
    max_capacity = 2
  }
}

# Weekdays 7 PM: Scale down to 0
resource "aws_appautoscaling_scheduled_action" "scale_down_weekdays" {
  name               = "scale-down-weekdays"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ec2.resource_id
  scalable_dimension = aws_appautoscaling_target.ec2.scalable_dimension
  schedule           = "cron(0 19 ? * MON-FRI *)" # 7 PM UTC weekdays

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}

# Weekends: Force shutdown tasks
resource "aws_appautoscaling_scheduled_action" "scale_down_weekends" {
  name               = "scale-down-weekends"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ec2.resource_id
  scalable_dimension = aws_appautoscaling_target.ec2.scalable_dimension
  schedule           = "cron(0 0 ? * SAT,SUN *)" # Midnight Sat/Sun

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}

# FARGATE Auto Scaling Policy
resource "aws_appautoscaling_target" "fargate" {
  max_capacity       = 2
  min_capacity       = 0
  resource_id        = "service/${aws_ecs_cluster.backend_cluster.name}/${aws_ecs_service.fargate_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

resource "aws_appautoscaling_policy" "cpu_policy" {
  name               = "fargate-cpu-scale"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.fargate.resource_id
  scalable_dimension = aws_appautoscaling_target.fargate.scalable_dimension
  service_namespace  = aws_appautoscaling_target.fargate.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 50.0 # Target CPU utilization %
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}






