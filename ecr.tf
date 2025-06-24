# ECR Repository Creation
resource "aws_ecr_repository" "main" {
  name                 = "backend-image"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = var.tag_name_for_project
    Environment = var.tag_env_for_project
  }
}

# This Policy will delete the Oldest Image from the ECR Repo if it has more than 5 Images
resource "aws_ecr_lifecycle_policy" "ecr_rule" {
  repository = aws_ecr_repository.main.name

  policy = <<EOF
  {
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Keep last 5 images",
        "selection" : {
          "tagStatus" : "tagged",
          "tagPrefixList" : ["Dev"],
          "countType" : "imageCountMoreThan",
          "countNumber" : 5
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  }
  EOF
}
