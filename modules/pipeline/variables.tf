# modules/pipeline/variables.tf
# Variables para el módulo Pipeline

variable "pipeline_name" {
  description = "Nombre base del pipeline"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, pre, pro)"
  type        = string
}

variable "github_connection_arn" {
  description = "ARN de la conexión de GitHub/CodeStar"
  type        = string
}

variable "github_repository" {
  description = "Repositorio de GitHub (formato: owner/repo)"
  type        = string
}

variable "github_branch" {
  description = "Rama de GitHub a monitorear"
  type        = string
}

variable "ecr_repository_url" {
  description = "URL del repositorio ECR"
  type        = string
}

variable "lambda_function_name" {
  description = "Nombre de la función Lambda a actualizar"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN de la función Lambda"
  type        = string
}

variable "build_compute_type" {
  description = "Tipo de cómputo para CodeBuild"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_image" {
  description = "Imagen Docker para CodeBuild"
  type        = string
  default     = "aws/codebuild/standard:5.0"
}

variable "buildspec_content" {
  description = "Contenido del buildspec.yml"
  type        = string
}

variable "build_environment_variables" {
  description = "Variables de entorno adicionales para el build"
  type        = map(string)
  default     = {}
}

variable "auto_deploy" {
  description = "Si se debe hacer deploy automático después del build"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}