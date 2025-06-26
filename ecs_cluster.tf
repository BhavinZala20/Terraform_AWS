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

resource "aws_ecs_cluster_capacity_providers" "capacity" {
  cluster_name       = aws_ecs_cluster.backend_cluster.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "ecs_instance" {
  ami                         = data.aws_ami.ecs.id # ✅ Use ECS-optimized AMI
  instance_type               = "t2.micro"
  key_name                    = "terraform-key"
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.name
  vpc_security_group_ids      = [aws_security_group.ecs_tasks.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "ECS_CLUSTER=Backend_ecs_cluster" >> /etc/ecs/ecs.config
              systemctl restart ecs
            EOF

  tags = {
    Name = "ecs-instance"
  }
}




