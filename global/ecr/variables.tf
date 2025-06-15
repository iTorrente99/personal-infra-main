# Variables para los recursos ECR globales

variable "aws_region" {
  description = "Región de AWS para el provider"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Nombre del proyecto, usado para nombrar los repositorios ECR"
  type        = string
  default     = "personal-app"
}

variable "snapshots_retention_count" {
  description = "Número de imágenes a retener en el repositorio de snapshots"
  type        = number
  default     = 15
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}