# modules/ecr/main.tf
# Módulo para crear repositorios ECR

# Repositorio para imágenes de desarrollo (Snapshots)
resource "aws_ecr_repository" "snapshots" {
  name = "${var.project_name}-snapshots"
  
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = merge(
    var.common_tags,
    {
      Type = "Development"
      Description = "Snapshots repository for development images"
    }
  )
}

# Política de ciclo de vida para snapshots
resource "aws_ecr_lifecycle_policy" "snapshots_policy" {
  repository = aws_ecr_repository.snapshots.name
  
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Mantener solo las últimas ${var.snapshots_retention_count} imágenes"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.snapshots_retention_count
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# Repositorio para imágenes de producción (Releases)
resource "aws_ecr_repository" "releases" {
  name = "${var.project_name}-releases"
  
  image_tag_mutability = "IMMUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = merge(
    var.common_tags,
    {
      Type = "Production"
      Description = "Releases repository for production images"
    }
  )
}

# Política para limpiar imágenes sin etiqueta
resource "aws_ecr_lifecycle_policy" "releases_untagged_policy" {
  repository = aws_ecr_repository.releases.name
  
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Expirar imágenes sin etiqueta después de 1 día"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 1
      }
      action = {
        type = "expire"
      }
    }]
  })
}