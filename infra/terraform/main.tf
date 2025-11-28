terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }

  backend "s3" {
    bucket         = "hng13-stage6-state-bucket"
    key            = "hng13-stage6/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "hng13-stage6-state-lock"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "HNG13-Stage6"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}
