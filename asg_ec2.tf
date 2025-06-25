# resource "aws_autoscaling_group" "ec2_asg" {
#   # ... other configuration, including potentially other tags ...
#   min_size = 1
#   max_size = 2
#   tag {
#     key                 = "AmazonECSManaged"
#     value               = true
#     propagate_at_launch = true
#   }
# }

# resource "aws_ecs_capacity_provider" "ec2_cp" {
#   name = "EC2 ASG"

#   auto_scaling_group_provider {
#     auto_scaling_group_arn         = aws_autoscaling_group.ec2_asg.arn
#     managed_termination_protection = "ENABLED"

#     managed_scaling {
#       maximum_scaling_step_size = 1000
#       minimum_scaling_step_size = 1
#       status                    = "ENABLED"
#       target_capacity           = 10
#     }
#   }
# }

# resource "aws_launch_template" "main" {
#   name          = "Launch Template for EC2"
#   image_id      = data.aws_ami.ecs.id
#   instance_type = "t2.micro"

#   network_interfaces {
#     associate_public_ip_address = false
#     security_groups             = aws_security_group.ecs_tasks
#   }

#   tag_specifications {
#     resource_type = "instance"
#     tags = {
#       Name        = var.tag_name_for_project
#       Environment = var.tag_env_for_project
#     }
#   }
# }

# resource "aws_autoscaling_group" "ec2_asg" {
#   name                      = "EC2 Auto Scaling Group"
#   max_size                  = 2
#   min_size                  = 1
#   desired_capacity          = 1
#   health_check_grace_period = 300
#   #   health_check_type         = "ELB"
#   availability_zones = var.public_subnet_cidrs

# }











