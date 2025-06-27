# This Task Definition is for EC2 launch type using BRIDGE network mode
resource "aws_ecs_task_definition" "ec2" {
  family                   = "ec2_service"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  memory                   = var.ecs_ec2_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = var.ecs_ec2_cpu

  container_definitions = jsonencode([
    {
      name      = "ec2_task",
      image     = "nginx",
      essential = true,
      portMappings = [
        {
          containerPort = var.ecs_task_definition_ec2_container_port,
          hostPort      = var.ecs_task_definition_ec2_host_port,
          protocol      = "tcp"
        }
      ],
      memory = var.ecs_ec2_memory,
      cpu    = var.ecs_ec2_cpu
    }
  ])

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

# # This Task Definition is for FARGATE launch type
# resource "aws_ecs_task_definition" "fargate" {
#   family                   = "test"
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   cpu                      = var.ecs_fargate_cpu
#   memory                   = var.ecs_fargate_memory
#   container_definitions    = <<TASK_DEFINITION
#   [
#     {
#       "name": "farget_task",
#       "image": "${aws_ecr_repository.main.repository_url}",
#       "cpu": "${var.ecs_fargate_cpu}",
#       "memory": "${var.ecs_fargate_memory}",
#       "essential": true
#     }
#   ]
#     TASK_DEFINITION
# }



