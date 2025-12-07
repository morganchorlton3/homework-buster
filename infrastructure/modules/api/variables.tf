variable "deployment_prefix" {
  description = "Deployment prefix for all resources"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID for JWT validation"
  type        = string
}

variable "source_path" {
  description = "Path to the source code directory (should contain requirements.txt for dependencies)"
  type        = string
  default     = "../../api"
}

variable "build_in_docker" {
  description = "Build Lambda package in Docker container for consistent builds"
  type        = bool
  default     = true
}

variable "allowed_origins" {
  description = "Allowed CORS origins for API Gateway"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

