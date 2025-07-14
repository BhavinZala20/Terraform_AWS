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

        # secrets = [
        #   {
        #     name      = "DB_USER"
        #     valueFrom = "${data.aws_secretsmanager_secret.by-name.arn}:username::"
        #   },
        #   {
        #     name      = "DB_PASS"
        #     valueFrom = "${data.aws_secretsmanager_secret.by-name.arn}:password::"
        #   },
        # ]

        # environment = [
        #   {
        #     name  = "DB_HOST"
        #     value = aws_db_instance.main.endpoint
        #   }
        # ]

      }
    ]
  )

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

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
        image     = "nginx",
        essential = true
        portMappings = [
          {
            containerPort = var.ecs_task_definition_fargate_container_port
            protocol      = "tcp"
          }
        ],

        cpu    = var.ecs_fargate_cpu
        memory = var.ecs_fargate_memory

        # secrets = [
        #   {
        #     name      = "DB_USER"
        #     valueFrom = "${data.aws_secretsmanager_secret.by-name.arn}:username::"
        #   },
        #   {
        #     name      = "DB_PASS"
        #     valueFrom = "${data.aws_secretsmanager_secret.by-name.arn}:password::"
        #   },

        # ]

        # environment = [
        #   {
        #     name  = "DB_HOST"
        #     value = aws_db_instance.main.endpoint
        #   }
        # ]
      }
    ]
  )

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}


