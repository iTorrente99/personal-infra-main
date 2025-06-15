# modules/lambda/variables.tf
# Variables para el módulo Lambda

variable "function_base_name" {
  description = "Nombre base de la función (sin sufijo de ambiente)"
  type        = string
}

variable "environment" {
  description = "Ambiente donde se despliega (dev, pre, pro)"
  type        = string
  validation {
    condition     = contains(["dev", "pre", "pro"], var.environment)
    error_message = "Environment debe ser dev, pre o pro"
  }
}

variable "image_uri" {
  description = "URI de la imagen Docker en ECR"
  type        = string
}

variable "timeout" {
  description = "Timeout de la función en segundos"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Memoria asignada a la función en MB"
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Variables de entorno para la Lambda"
  type        = map(string)
  default     = {}
}

variable "additional_policy_arns" {
  description = "ARNs de políticas IAM adicionales para adjuntar al rol"
  type        = list(string)
  default     = []
}

variable "inline_policy" {
  description = "Política IAM inline en formato JSON"
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "Días de retención para los logs de CloudWatch"
  type        = number
  default     = 7
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}