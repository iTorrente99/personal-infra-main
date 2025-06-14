variable "aws_region" {
  description = "La region de AWS donde se desplegarán los recursos."
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "El nombre del proyecto, usado para nombrar recursos"
  type        = string
  default     = "personal-app"
}