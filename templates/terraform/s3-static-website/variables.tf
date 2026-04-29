variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment_name" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "bucket_name" {
  description = "S3 bucket name (auto-generated if empty)"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain name for the website (optional)"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ACM Certificate ARN for custom domain"
  type        = string
  default     = ""
}

variable "default_root_object" {
  description = "Default root object"
  type        = string
  default     = "index.html"
}
