variable "tag_name_for_project" {
  type = string
}

variable "tag_env_for_project" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for public subnets, one per AZ"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for private subnets, one per AZ"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 Bucket for Frontend Hosting"
}

variable "cloudfront-dist_allowed_methods" {
  type        = list(string)
  description = "CloudFront Allowed Methods"
}

variable "cloudfront-dist_cached_methods" {
  type        = list(string)
  description = "CloudFront Cached Methods"
}

variable "cloudfront-dist_cache_policy_id" {
  type        = string
  description = "CloudFront Cache Policy ID"
}

variable "ecs_task_definition_ec2_container_port" {
  type        = number
  description = "Container Port for ECS Task Definition"
}

variable "ecs_task_definition_ec2_host_port" {
  type        = number
  description = "Host Port for ECS Task Definition"
}

variable "ecs_ec2_memory" {
  type        = number
  description = "Memory for EC2 Launch Type"
}

variable "ecs_ec2_cpu" {
  type        = number
  description = "CPU for the EC2 Launch Type"
}

variable "ecs_fargate_memory" {
  type        = number
  description = "Memory for FARGATE Launch Type"
}

variable "ecs_fargate_cpu" {
  type        = number
  description = "CPU for the FARGATE Launch Type"
}

variable "ecs_ec2_service_lb_containerPort" {
  type        = number
  description = "ECS Service EC2 Container Port"
}

variable "ecs_task_definition_fargate_container_port" {
  type        = number
  description = "ECS Service FARGATE Container Port"
}

variable "allocated_storage" {
  type        = number
  description = "RDS DB storage "
}

variable "max_allocated_storage" {
  type        = number
  description = "Maximum Storage for RDS DB"
}

variable "engine" {
  type        = string
  description = "Database Engine"
}

variable "engine_version" {
  type        = number
  description = "Database Engine Version"
}

variable "instance_class" {
  type        = string
  description = "Instance Class for DB Engine"
}
