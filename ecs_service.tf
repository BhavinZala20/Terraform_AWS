
resource "aws_ecs_service" "ec2-service" {
  name                = "Backend_Service"
  cluster             = aws_ecs_cluster.backend_cluster.id
  task_definition     = aws_ecs_task_definition.ec2.arn
  launch_type         = "EC2"
  scheduling_strategy = "REPLICA"
  desired_count       = 2
  depends_on          = [aws_instance.ecs_instance]

  load_balancer {
    target_group_arn = aws_alb_target_group.ec2_target.arn
    container_name   = "ec2_task"
    container_port   = var.ecs_ec2_service_lb_containerPort
  }

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

# ECS Service for FARGATE
resource "aws_ecs_service" "fargate_service" {
  name            = "Fargate_Service"
  cluster         = aws_ecs_cluster.backend_cluster.id
  task_definition = aws_ecs_task_definition.fargate.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_tasks.id]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.fargate_target.arn
    container_name   = "fargate_task"
    container_port   = var.ecs_task_definition_fargate_container_port
  }
  # depends_on = [aws_alb_listener.front_end]

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}



