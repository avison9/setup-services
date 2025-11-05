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

  default_tags {
    tags = merge(var.default_tags, {
      Terraform   = "true"
      Environment = var.environment
      Component   = "rds"
      DBName      = var.identifier
    })
  }
}