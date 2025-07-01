# resource "aws_kms_key" "default" {
#   description             = "KMS Key for RDS"
#   deletion_window_in_days = 7
#   is_enabled              = true
#   enable_key_rotation     = true

#   tags = {
#     Name        = var.tag_name_for_project
#     Environment = var.tag_env_for_project
#   }
# }
