module "auth" {
  source = "./modules/auth"

  deployment_prefix = terraform.workspace
}

module "api" {
  source = "./modules/api"

  deployment_prefix    = terraform.workspace
  cognito_user_pool_id = module.auth.user_pool_id
  allowed_origins      = ["*"]
}