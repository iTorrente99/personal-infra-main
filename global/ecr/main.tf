# global/ecr/main.tf
# Configuración de recursos ECR compartidos entre todos los ambientes

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "tf-state-personal-infra-main"
    key            = "global/ecr/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Instancia del módulo ECR
module "ecr_repositories" {
  source = "../../modules/ecr"

  project_name              = var.project_name
  snapshots_retention_count = var.snapshots_retention_count

  common_tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
    Component = "ECR"
  }
}
