terraform {
  cloud {
    organization = "organization_vngo"
    workspaces {
      name = "learn-terraform-aws"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.53"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = local.region
}