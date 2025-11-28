module "auth" {
  source = "./modules/auth"

  deployment_prefix = terraform.workspace
}