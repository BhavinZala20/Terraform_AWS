data "aws_secretsmanager_secret" "by-name" {
  name       = "rds-9"
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

  # Allow ECS tasks to connect
  ingress {
    description     = "ECS access"
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
  deletion_protection                 = true
  vpc_security_group_ids              = [aws_security_group.rds.id]
  iam_database_authentication_enabled = true
  depends_on                          = [aws_secretsmanager_secret.main]
  #   manage_master_user_password = true

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

# resource "null_resource" "rds_init_script" {
#   provisioner "local-exec" {
#     command = <<EOT
# echo "⏳ Waiting for RDS..."
# sleep 60

# SECRET_JSON='${data.aws_secretsmanager_secret_version.secret.secret_string}'
# PASSWORD=$(echo "$SECRET_JSON" | jq -r .password)
# USERNAME=$(echo "$SECRET_JSON" | jq -r .username)

# mysql -h ${aws_db_instance.main.address} -P 3306 -u "$USERNAME" -p"$PASSWORD" ${aws_db_instance.main.db_name} < init.sql
# EOT

#     interpreter = ["/bin/bash", "-c"]
#   }

#   depends_on = [aws_db_instance.main]
# }


