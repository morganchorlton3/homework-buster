output "user_pool_client_id" {
  value = module.auth.user_pool_client_id
}

output "api_url" {
  description = "URL of the API Lambda function"
  value       = module.api.lambda_function_url
}

output "api_function_name" {
  description = "Name of the API Lambda function"
  value       = module.api.lambda_function_name
}