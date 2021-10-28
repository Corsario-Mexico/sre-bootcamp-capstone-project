# AWS provider example
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# AWS Provider configuration, using variables from variables.tf
provider "aws" {
  default_tags {
    tags = {
      student = "David Sol"
    }
  }
}