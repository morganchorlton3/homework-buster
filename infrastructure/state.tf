terraform {
  backend "s3" {
    bucket               = "homework-buster-tf-state"
    workspace_key_prefix = "environments"
    key                  = ".tfstate"
    region               = "eu-west-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
}

# Get ECR authorization token
data "aws_ecr_authorization_token" "token" {}

# Configure Docker provider with ECR authentication
provider "docker" {
  registry_auth {
    address  = data.aws_ecr_authorization_token.token.proxy_endpoint
    username = "AWS"
    password = data.aws_ecr_authorization_token.token.password
  }
}
