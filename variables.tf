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
  type        = string
  description = "Database Engine Version"
}

variable "instance_class" {
  type        = string
  description = "Instance Class for DB Engine"
}

variable "alb_sg_from_port" {
  type        = number
  description = "Ingress port for ALB sg"
}

variable "alb_sg_to_port" {
  type        = number
  description = "Ingress port for ALB sg"
}

variable "alg_sg_protocol" {
  type        = string
  description = "Protocol for ALG sg"
}

variable "alb_listener_port" {
  type        = number
  description = "Listener port for ALB"
}

variable "alb_listener_protocol" {
  type        = string
  description = "Protocol for ALB Listener"
}

variable "alb_target_group_port" {
  type        = number
  description = "Target Group Port Number"
}

variable "alb_target_group_protocol" {
  type        = string
  description = "Target Group Protocol"
}

variable "alb_dereg_delay" {
  type        = number
  description = "Deregistration Delay"
}

variable "alb_target_type" {
  type        = string
  description = "Target Type for EC2 Target Group"
}

variable "ec2_alb_healthy_threshold" {
  type = number
}

variable "ec2_alb_unhealthy_threshold" {
  type = number
}

variable "ec2_health_check_interval" {
  type = number
}

# variable "ec2_health_check_port" {
#   type = number
# }

variable "ec2_health_check_protocol" {
  type = string
}

variable "ec2_health_check_timeout" {
  type = number
}

variable "fargate_tg_port" {
  type = number
}

variable "fargate_tg_protocol" {
  type = string
}

variable "fargate_tg_targate_type" {
  type = string
}

variable "fargate_tg_dereg_delay" {
  type = number
}

variable "fargate_health_check_healthy_threshold" {
  type = number
}

variable "fargate_health_check_unhealthy_threshold" {
  type = number
}

variable "fargate_health_check_interval" {
  type = number
}

variable "fargate_health_check_timeout" {
  type = number
}

variable "fargate_health_check_protocol" {
  type = string
}
