resource "random_pet" "name" {
  length = 2
}

resource "aws_secretsmanager_secret" "main" {
  name                    = "rds-${random_pet.name.id}"
  recovery_window_in_days = 7
  description             = "RDS Admin Password"

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

resource "random_password" "password" {
  length           = 20
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id = aws_secretsmanager_secret.main.id
  secret_string = jsonencode(
    {
      username = "admin"
      password = random_password.password.result
    }
  )
}
