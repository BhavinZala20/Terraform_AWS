# This Task Definition is for EC2 launch type using BRIDGE network mode
resource "aws_ecs_task_definition" "ec2" {
  family                   = "ec2_service"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  memory                   = var.ecs_ec2_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = var.ecs_ec2_cpu
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode(
    [
      {
        name      = "ec2_task",
        image     = "bhavin20/ci-cd:latest",
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

        environment = [
          {
            name  = "DB_HOST"
            value = aws_db_instance.main.address
          },
          {
            name  = "AWS_REGION"
            value = "ap-south-1"
          },
          {
            name  = "AWS_SDK_LOAD_CONFIG"
            value = "1"
          },
          {
            name  = "DB_SECRET_NAME"
            value = aws_secretsmanager_secret.main.name
          }
        ]
      }
    ]
  )

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

# Task Definition for the FARGATE Launch Type
resource "aws_ecs_task_definition" "fargate" {
  family                   = "fargate-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_fargate_cpu
  memory                   = var.ecs_fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode(
    [
      {
        name      = "fargate_task"
        image     = "bhavin20/ci-cd:latest"
        essential = true
        portMappings = [
          {
            containerPort = var.ecs_task_definition_fargate_container_port
            protocol      = "tcp"
          }
        ]

        cpu    = var.ecs_fargate_cpu
        memory = var.ecs_fargate_memory

        environment = [
          {
            name  = "DB_HOST"
            value = aws_db_instance.main.address
          },
          {
            name  = "AWS_REGION"
            value = "ap-south-1"
          },
          {
            name  = "AWS_SDK_LOAD_CONFIG"
            value = "1"
          },
          {
            name  = "DB_SECRET_NAME"
            value = aws_secretsmanager_secret.main.name
          }
        ]
      }
    ]
  )

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}


