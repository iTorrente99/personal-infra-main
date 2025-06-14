provider "aws" {
  region = var.aws_region
}

# --- 1. Repositorio ECR para imágenes de DESARROLLO (Snapshots) ---
resource "aws_ecr_repository" "snapshots" {
  name = "${var.project_name}-snapshots"

  # Mutable, porque las etiquetas de desarrollo se sobreescribiran a menudo
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Environment = "Development"
  }
}

# --- Lifecycle policy para el repositorio de snapshots ---
# Crucial para evitar acumulacion de costes y basura
resource "aws_ecr_lifecycle_policy" "snapshots_policy" {
  # Asocia esta política al repositorio 'snapshots' que definimos arriba
  repository = aws_ecr_repository.snapshots.name

  # La política en sí, ahora en formato de texto JSON
  policy = jsonencode({
    rules = [{
      rulePriority = 1,
      description  = "Mantener solo las últimas 15 imágenes de desarrollo",
      selection = {
        tagStatus   = "any",
        countType   = "imageCountMoreThan",
        countNumber = 15
      },
      action = {
        type = "expire"
      }
    }]
  })
}

# --- 2. Repositorio ECR para imágenes ESTABLES (Releases) ---
resource "aws_ecr_repository" "releases" {
  name = "${var.project_name}-releases" # ej: personal-app-releases

  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Environment = "Production"
  }
}

# Política para limpiar imágenes sin etiqueta en el repo de releases.
# Es una buena práctica para mantenerlo limpio de subidas fallidas.
resource "aws_ecr_lifecycle_policy" "releases_untagged_policy" {
  repository = aws_ecr_repository.releases.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1,
      description  = "Expirar imágenes sin etiqueta (untagged) después de 1 día",
      selection = {
        tagStatus   = "untagged",
        countType   = "sinceImagePushed",
        countUnit   = "days",
        countNumber = 1
      },
      action = {
        type = "expire"
      }
    }]
  })
}