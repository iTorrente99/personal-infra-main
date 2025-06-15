# modules/ecr/variables.tf
# Variables para el módulo ECR

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "snapshots_retention_count" {
  description = "Número de imágenes a retener en snapshots"
  type        = number
  default     = 15
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}