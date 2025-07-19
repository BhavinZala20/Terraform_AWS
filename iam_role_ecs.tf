# IAM Policy Documents
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_instance_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ECS Task Execution Role (for pulling images, logging, secrets injection)
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ECSTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Optional: SSM access if you're enabling ECS Exec for Fargate or EC2 containers
resource "aws_iam_role_policy_attachment" "ecs_task_execution_ssm" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

# ECS Task Role (used by application code inside container)
resource "aws_iam_role" "ecs_task_role" {
  name               = "ECSTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

# SecretsManager access for runtime SDK calls from container app
resource "aws_iam_role_policy_attachment" "ecs_task_role_secrets" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Optional: SSM access if the container app wants to access SSM Parameters
resource "aws_iam_role_policy_attachment" "ecs_task_role_ssm" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

# ECS EC2 Instance Role
resource "aws_iam_role" "ecs_instance_role" {
  name               = "ECSInstanceRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Optional: SSM Session Manager access to EC2 instances
resource "aws_iam_role_policy_attachment" "ecs_instance_ssm" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ECSInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}
