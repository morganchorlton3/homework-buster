# Get current AWS region
data "aws_region" "current" {}

module "api_container" {
  source  = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version = "~> 8.0"

  create_ecr_repo  = true
  ecr_repo         = "${var.deployment_prefix}-homework-buster-api"
  ecr_force_delete = true
  ecr_repo_lifecycle_policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Keep only the last 3 images",
        "selection" : {
          "tagStatus" : "any",
          "countType" : "imageCountMoreThan",
          "countNumber" : 3
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })

  use_image_tag = true
  image_tag     = local.api_hash

  source_path      = local.project_root
  docker_file_path = "api.Dockerfile"
  platform         = "linux/amd64"
}

module "api_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 8.0"

  function_name = "${var.deployment_prefix}-homework-buster-api"
  description   = "Homework Buster FastAPI application"
  timeout       = 30

  create_package = false
  package_type = "Image"
  image_uri    = module.api_container.image_uri

  environment_variables = {
    COGNITO_USER_POOL_ID = var.cognito_user_pool_id
    AWS_REGION           = data.aws_region.current.name
  }

  cloudwatch_logs_retention_in_days = 7

  create_lambda_function_url = true
  cors = {
    allow_credentials = true
    allow_origins     = var.allowed_origins
    allow_methods     = ["*"]
    allow_headers     = ["*"]
    expose_headers    = ["*"]
    max_age           = 86400
  }

  tags = var.tags
}

