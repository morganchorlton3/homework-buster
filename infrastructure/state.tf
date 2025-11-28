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
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
