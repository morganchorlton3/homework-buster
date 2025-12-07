# API Lambda Module

Terraform module for deploying the Homework Buster FastAPI application to AWS Lambda.

## Usage

```hcl
module "api" {
  source = "./modules/api"

  deployment_prefix    = "my-app"
  cognito_user_pool_id = "us-east-1_XXXXXXXXX"
  aws_region           = "us-east-1"
  allowed_origins      = ["https://example.com"]
}
```

## Requirements

- The `terraform-aws-modules/lambda/aws` module (version ~> 8.0)
- Python 3.11 runtime
- Poetry for dependency management (used during build)

## Build Process

The Lambda function is built automatically by Terraform using the `terraform-aws-lambda` module. The build process:

1. **Automatically detects `requirements.txt`** in the `source_path` directory
2. **Installs dependencies** using pip (in Docker container by default for consistency)
3. **Packages the code and dependencies** into a deployment package
4. **Deploys to Lambda**

The `requirements.txt` file should be kept in sync with `pyproject.toml`. To regenerate it:

```bash
poetry export -f requirements.txt --output api/requirements.txt --without-hashes
```

**Note:** The build script (`scripts/build_lambda.sh`) is optional and only needed for local testing. Terraform handles the build during deployment.

## Environment Variables

- `COGNITO_USER_POOL_ID`: Cognito User Pool ID for JWT validation
- `AWS_REGION`: AWS region (defaults to us-east-1)

## Outputs

- `lambda_function_name`: Name of the Lambda function
- `lambda_function_arn`: ARN of the Lambda function
- `lambda_function_url`: URL of the Lambda function (Function URL)
- `lambda_function_invoke_arn`: Invoke ARN of the Lambda function

