# environments/dev/variables.tf
# Variables para el ambiente de desarrollo

variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "personal-app"
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "dev"
}

variable "github_connection_arn" {
  description = "ARN de la conexión de GitHub/CodeStar"
  type        = string
  default     = "arn:aws:codeconnections:eu-west-1:590184031333:connection/4a1b0335-5d89-4d95-82fa-926515d75a62"
}

variable "github_repository" {
  description = "Repositorio de GitHub (formato: owner/repo)"
  type        = string
  default     = "iTorrente99/lambda_personal-app_get-journal-data"
}

variable "github_branch" {
  description = "Rama de GitHub a monitorear"
  type        = string
  default     = "dev"
}

variable "lambda_timeout" {
  description = "Timeout de la función Lambda en segundos"
  type        = number
  default     = 10
}

variable "lambda_memory_size" {
  description = "Memoria asignada a la función Lambda en MB"
  type        = number
  default     = 128
}

# ===== VARIABLES PARA AMPLIFY (FRONTEND) =====

variable "frontend_github_repository" {
  description = "URL del repositorio de GitHub del frontend"
  type        = string
  default     = "https://github.com/iTorrente99/personal-app-frontend"
}

variable "frontend_branch_name" {
  description = "Branch del frontend a desplegar"
  type        = string
  default     = "master"
}

variable "frontend_custom_domain" {
  description = "Dominio personalizado para el frontend (opcional)"
  type        = string
  default     = null # Cambia a "tudominio.com" cuando lo tengas
}

variable "frontend_framework" {
  description = "Framework del frontend (react, vite, nextjs, etc.)"
  type        = string
  default     = "vite"
  
  validation {
    condition     = contains(["react", "vite", "nextjs", "vue", "angular"], var.frontend_framework)
    error_message = "El framework debe ser uno de: react, vite, nextjs, vue, angular"
  }
}

variable "frontend_basic_auth_password" {
  description = "Contraseña para autenticación básica en entorno dev"
  type        = string
  sensitive   = true
  default     = "changeme123!" # Cambia esto en terraform.tfvars
}