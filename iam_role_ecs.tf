# Assume Role Policy for ECS Task Execution Role
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ECSTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

# Attach AWS-managed policy for ECS Task Execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Policy that container use to read the cred from Secret Manager
resource "aws_iam_role_policy_attachment" "secrets_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Allows ECS Tasks to call GetSecretValue to fetch the password
resource "aws_iam_policy_attachment" "ecs_secrets_access" {
  name       = "ecs-task-secrets-access"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Assume Role Policy for EC2 to join ECS cluster
data "aws_iam_policy_document" "ecs_instance_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ECS Instance Role
resource "aws_iam_role" "ecs_instance_role" {
  name               = "ECSInstanceRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_assume_role.json
}

# Attach ECS Instance Policy to allow EC2 to connect to ECS
resource "aws_iam_role_policy_attachment" "ecs_instance_policy_attach" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# IAM Instance Profile for EC2
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ECSInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}


