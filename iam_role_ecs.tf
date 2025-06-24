# ECS Cluster Task Execution Role

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "main" {
  name               = "ECSTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}


