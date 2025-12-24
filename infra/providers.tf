terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0, < 4.0.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region                      = var.aws_region
  access_key                  = var.aws_access_key
  secret_key                  = var.aws_secret_key
  # Altere para false e forneça um ID fixo
  skip_requesting_account_id  = false 
  
  # Força um ID de conta válido para o LocalStack (comum ser 000000000000)
  allowed_account_ids         = ["000000000000"]
  skip_credentials_validation = true
  s3_force_path_style         = true
  # Map AWS service endpoints to LocalStack edge URL so provider routes calls
  # (single `endpoints` block required by the provider)
  endpoints {
    s3        = var.localstack_endpoint
    s3control = var.localstack_endpoint
    sts       = var.localstack_endpoint
    iam       = var.localstack_endpoint
  }
}
