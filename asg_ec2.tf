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
