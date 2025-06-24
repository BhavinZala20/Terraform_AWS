# ECS Cluster Creation
resource "aws_ecs_cluster" "backend_cluster" {
  name = "Backend_ecs_cluster"

  # This block will be used for enhanced cloudwatch logs
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
    
  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

resource "aws_ecs_cluster_capacity_providers" "fargate_asg" {
  cluster_name       = aws_ecs_cluster.backend_cluster.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}
