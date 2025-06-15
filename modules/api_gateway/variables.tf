variable "api_name" {
  description = "Nombre para la API REST Gateway"
  type        = string
}

variable "environment" {
  description = "Nombre del stage de despliegue (dev, pre, pro)"
  type        = string
}

variable "lambda_integrations" {
  description = "Un mapa de lambdas para integrar. La clave es el path del recurso."
  type = map(object({
    lambda_invoke_arn = string
    lambda_function_arn = string
  }))
}

variable "common_tags" {
  description = "Tags comunes"
  type        = map(string)
  default     = {}
}