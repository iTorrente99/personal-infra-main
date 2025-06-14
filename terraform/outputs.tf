output "ecr_snapshots_url" {
  description = "La URL del repositorio ECR para imágenes de desarrollo."
  value       = aws_ecr_repository.snapshots.repository_url
}

output "ecr_snapshots_arn" {
  description = "El ARN del repositorio ECR para imágenes de desarrollo."
  value       = aws_ecr_repository.snapshots.arn
}

output "ecr_releases_url" {
  description = "La URL del repositorio ECR para imágenes estables."
  value       = aws_ecr_repository.releases.repository_url
}

output "ecr_releases_arn" {
  description = "El ARN del repositorio ECR para imágenes estables."
  value       = aws_ecr_repository.releases.arn
}