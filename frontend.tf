# resource "aws_s3_bucket" "main" {
#   bucket = var.s3_bucket_name
#   region = "ap-south-1"

#   tags = {
#     Name        = var.tag_name_for_project
#     Environment = var.tag_env_for_project
#   }
# }

# resource "aws_cloudfront_distribution" "main" {
#   enabled             = true
#   default_root_object = "index.html"
#   wait_for_deployment = true

#   origin {
#     domain_name              = aws_s3_bucket.main.bucket_domain_name
#     origin_access_control_id = aws_cloudfront_origin_access_control.main.id
#     origin_id                = aws_s3_bucket.main.bucket
#   }

#   default_cache_behavior {
#     allowed_methods        = var.cloudfront-dist_allowed_methods
#     cached_methods         = var.cloudfront-dist_cached_methods
#     target_origin_id       = aws_s3_bucket.main.id
#     viewer_protocol_policy = "redirect-to-https"
#     cache_policy_id        = var.cloudfront-dist_cache_policy_id
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }

#   tags = {
#     Name        = var.tag_name_for_project
#     Environment = var.tag_env_for_project
#   }
# }

# resource "aws_cloudfront_origin_access_control" "main" {
#   name                              = "s3-cloufront-oac-test"
#   origin_access_control_origin_type = "s3"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }

# data "aws_iam_policy_document" "cloudfront_oac_access" {
#   statement {
#     principals {
#       identifiers = ["cloudfront.amazonaws.com"]
#       type        = "Service"
#     }

#     actions   = ["s3:GetObject"]
#     resources = ["${aws_s3_bucket.main.arn}/*"]

#     condition {
#       test     = "StringEquals"
#       values   = [aws_cloudfront_distribution.main.arn]
#       variable = "AWS:SourceArn"
#     }
#   }
# }

# resource "aws_s3_bucket_policy" "main" {
#   bucket = aws_s3_bucket.main.id
#   policy = data.aws_iam_policy_document.cloudfront_oac_access.json
# }
