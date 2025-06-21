# Variables locales y valores calculados

locals {
  # Tags comunes para todos los recursos
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Repository  = var.infra_repository
  }
  
  ecr_snapshots_url = data.terraform_remote_state.global_ecr.outputs.snapshots_repository_url
  ecr_releases_url  = data.terraform_remote_state.global_ecr.outputs.releases_repository_url
}