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

variable "lambda_runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "nodejs18.x"
  validation {
    condition     = contains(["nodejs18.x", "nodejs20.x", "python3.11", "python3.12", "java17", "dotnet6", "provided.al2"], var.lambda_runtime)
    error_message = "Runtime must be a valid Lambda runtime."
  }
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory" {
  description = "Lambda function memory in MB"
  type        = number
  default     = 256
}

variable "enable_xray" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = true
}

variable "reserved_concurrent_executions" {
  description = "Reserved concurrent executions (0 for unlimited)"
  type        = number
  default     = 100
}
