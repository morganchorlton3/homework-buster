output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.api_lambda.lambda_function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.api_lambda.lambda_function_arn
}

output "lambda_function_url" {
  description = "URL of the Lambda function"
  value       = module.api_lambda.lambda_function_url
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = module.api_lambda.lambda_function_invoke_arn
}

