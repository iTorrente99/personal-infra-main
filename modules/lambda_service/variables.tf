variable "function_base_name" { type = string }
variable "environment" { type = string }
variable "github_connection_arn" { type = string }
variable "github_repository" { type = string }
variable "github_branch" { type = string }
variable "ecr_snapshots_url" { type = string }
variable "lambda_timeout" { type = number }
variable "lambda_memory_size" { type = number }
variable "common_tags" { type = map(string) }
variable "buildspec_path" {
  type        = string
  description = "Ruta al archivo buildspec.yml desde la raíz del entorno"
  default     = "./buildspec.yml"
}
variable "ecr_snapshots_name" {
  description = "Nombre del repositorio ECR de snapshots"
  type        = string
}
