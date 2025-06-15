# environments/dev/data.tf
# Data sources necesarios

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Obtener los outputs del módulo ECR global
data "terraform_remote_state" "global_ecr" {
  backend = "s3"
  
  config = {
    bucket = "tf-state-personal-infra-main"
    key    = "global/ecr/terraform.tfstate"
    region = "eu-west-1"
  }
}