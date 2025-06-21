# Variables para el módulo Amplify

variable "app_name" {
  description = "Nombre de la aplicación Amplify"
  type        = string
}

variable "github_repository" {
  description = "URL del repositorio de GitHub (dejar vacío para conectar manualmente)"
  type        = string
  default     = ""
}

variable "github_access_token" {
  description = "Token de acceso de GitHub (deprecado, usar OAuth manual)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "branch_name" {
  description = "Nombre del branch a desplegar"
  type        = string
  default     = "master"
}

variable "stage" {
  description = "Stage del branch (PRODUCTION, BETA, DEVELOPMENT, etc.)"
  type        = string
  default     = "PRODUCTION"
}

variable "framework" {
  description = "Framework del frontend (React, Vue, Angular, etc.)"
  type        = string
  default     = "React"
}

variable "build_spec" {
  description = "Build spec personalizado para Amplify (null para usar el default)"
  type        = string
  default     = null
}

variable "build_output_directory" {
  description = "Directorio de salida del build (dist, build, out, etc.)"
  type        = string
  default     = "dist"
}

variable "environment_variables" {
  description = "Variables de entorno para la aplicación"
  type        = map(string)
  default     = {}
}

variable "branch_environment_variables" {
  description = "Variables de entorno específicas del branch"
  type        = map(string)
  default     = {}
}

variable "custom_domain" {
  description = "Dominio personalizado (ej: miapp.com)"
  type        = string
  default     = null
}

variable "subdomains" {
  description = "Lista de subdominios a configurar"
  type = list(object({
    prefix      = string
    branch_name = string
  }))
  default = []
}

variable "enable_www_redirect" {
  description = "Habilitar redirección de www al dominio principal"
  type        = bool
  default     = true
}

variable "custom_rules" {
  description = "Reglas de redirección personalizadas"
  type = list(object({
    source = string
    target = string
    status = string
  }))
  default = []
}

variable "enable_basic_auth" {
  description = "Habilitar autenticación básica"
  type        = bool
  default     = false
}

variable "basic_auth_credentials" {
  description = "Credenciales para autenticación básica (formato: username:password)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}