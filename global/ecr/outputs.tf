# Outputs de recursos ECR globales

output "snapshots_repository_url" {
  description = "URL del repositorio de snapshots"
  value       = module.ecr_repositories.snapshots_repository_url
}

output "snapshots_repository_name" {
  description = "Nombre del repositorio de snapshots"
  value       = module.ecr_repositories.snapshots_repository_name
}

output "releases_repository_url" {
  description = "URL del repositorio de releases"
  value       = module.ecr_repositories.releases_repository_url
}

output "releases_repository_name" {
  description = "Nombre del repositorio de releases"
  value       = module.ecr_repositories.releases_repository_name
}