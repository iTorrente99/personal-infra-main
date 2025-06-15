# Outputs del módulo ECR

output "snapshots_repository_url" {
  description = "URL del repositorio ECR para snapshots"
  value       = aws_ecr_repository.snapshots.repository_url
}

output "snapshots_repository_arn" {
  description = "ARN del repositorio ECR para snapshots"
  value       = aws_ecr_repository.snapshots.arn
}

output "releases_repository_url" {
  description = "URL del repositorio ECR para releases"
  value       = aws_ecr_repository.releases.repository_url
}

output "releases_repository_arn" {
  description = "ARN del repositorio ECR para releases"
  value       = aws_ecr_repository.releases.arn
}

output "snapshots_repository_name" {
  description = "Nombre del repositorio de snapshots"
  value       = aws_ecr_repository.snapshots.name
}

output "releases_repository_name" {
  description = "Nombre del repositorio de releases"
  value       = aws_ecr_repository.releases.name
}