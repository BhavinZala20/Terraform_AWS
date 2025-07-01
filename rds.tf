data "aws_secretsmanager_secret" "by-name" {
  name       = "rds"
  depends_on = [aws_secretsmanager_secret.main]
}

data "aws_secretsmanager_secret_version" "secret" {
  secret_id = data.aws_secretsmanager_secret.by-name.id
}

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
  storage_type            = "gp2"
  allocated_storage       = var.allocated_storage # in GB
  max_allocated_storage   = var.max_allocated_storage
  db_name                 = "mydb"
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class # 2 vCPU, 1 GB Memory
  username                = "Admin"
  password                = data.aws_secretsmanager_secret_version.secret.secret_string
  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  storage_encrypted       = true
  backup_retention_period = 1
  database_insights_mode  = "standard"
  db_subnet_group_name    = aws_db_subnet_group.rds.name
  deletion_protection     = true
  vpc_security_group_ids  = [aws_security_group.rds.id]
  #   manage_master_user_password = true
  iam_database_authentication_enabled = true
  depends_on                          = [aws_secretsmanager_secret.main]

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}
