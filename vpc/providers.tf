# providers.tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }
  }
}

provider "aws" {
  region = var.region

  # Recommended: Use assume role in production
  # assume_role { ... }

  default_tags {
    tags = merge(var.default_tags, {
      Terraform   = "true"
      Environment = var.environment
      VPC         = var.vpc_name
    })
  }
}
