# Security Group for RDS Database Instance
resource "aws_security_group" "rds" {
  name        = "rds_sg"
  vpc_id      = aws_vpc.main.id
  description = "RDS Security Group"

  ingress {
    description     = "Inbound rule for RDS DB"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  # Allow your IP for local exec/init (if needed temporarily)
  ingress {
    description = "Local machine access (Bhavin)"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["14.99.102.226/32"]
  }

  egress {
    description = "Outbound rule for RDS DB"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

# Separate Subnet for the RDS Database Instance
resource "aws_db_subnet_group" "rds" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.private.*.id

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

resource "aws_db_instance" "main" {
  storage_type                        = "gp2"
  allocated_storage                   = var.allocated_storage # in GB
  max_allocated_storage               = var.max_allocated_storage
  db_name                             = "mydb"
  engine                              = var.engine
  engine_version                      = var.engine_version
  instance_class                      = var.instance_class # 2 vCPU, 1 GB Memory
  username                            = "admin"
  password                            = random_password.password.result
  parameter_group_name                = "default.mysql8.0"
  skip_final_snapshot                 = true
  publicly_accessible                 = false
  multi_az                            = false
  storage_encrypted                   = true
  backup_retention_period             = 1
  database_insights_mode              = "standard"
  db_subnet_group_name                = aws_db_subnet_group.rds.name
  deletion_protection                 = false
  vpc_security_group_ids              = [aws_security_group.rds.id]
  iam_database_authentication_enabled = true
  depends_on                          = [aws_secretsmanager_secret.main]

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

# module "start_rds_instances" {
#   source              = "github.com/julb/terraform-aws-lambda-auto-start-stop-rds-instances"
#   name                = "StartRDSInstances"
#   schedule_expression = "cron(30 1 ? * MON-FRI *)" # 7 AM 
#   action              = "start"
#   tags = {
#     Name        = var.tag_name_for_project,
#     Environment = var.tag_env_for_project
#   }
#   lookup_resource_tag = {
#     key   = "Environment"
#     value = "Dev"
#   }
# }

# module "stop_rds_instances" {
#   source              = "github.com/julb/terraform-aws-lambda-auto-start-stop-rds-instances"
#   name                = "StopRDSInstances"
#   schedule_expression = "cron(30 13 ? * MON-FRI *)" # 7 PM
#   action              = "stop"
#   tags = {
#     Name        = var.tag_name_for_project
#     Environment = var.tag_env_for_project
#   }
#   lookup_resource_tag = {
#     key   = "Environment"
#     value = "Dev"
#   }
# }
