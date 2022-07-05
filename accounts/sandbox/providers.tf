locals {
  account_id      = "847068433460"
  account_profile = "sandbox"
}

terraform {
  required_version = ">=1.1.4"
  required_providers {
    aws = {
      version = ">=4.0.0"
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket         = "terraform-state-storage-847068433460"
    key            = "kempy-api-test.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-847068433460"
    profile        = "sandbox"
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "us-west-2"
  profile = local.account_profile
}
provider "aws" {
  region  = "us-east-1"
  profile = local.account_profile
  alias   = "us-east-1"
}
provider "aws" {
  region  = "us-west-2"
  profile = local.account_profile
  alias   = "us-west-2"
}
