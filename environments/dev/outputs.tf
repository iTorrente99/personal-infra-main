# environments/dev/outputs.tf
# Outputs del ambiente DEV

# Lambda outputs
output "lambda_function_name" {
  description = "Nombre de la función Lambda"
  value       = module.lambda_get_journal_data.function_name
}

output "lambda_function_arn" {
  description = "ARN de la función Lambda"
  value       = module.lambda_get_journal_data.function_arn
}

output "lambda_invoke_arn" {
  description = "ARN de invocación de la Lambda"
  value       = module.lambda_get_journal_data.invoke_arn
}

output "lambda_role_arn" {
  description = "ARN del rol IAM de la Lambda"
  value       = module.lambda_get_journal_data.role_arn
}

output "lambda_role_name" {
  description = "Nombre del rol IAM de la Lambda"
  value       = module.lambda_get_journal_data.role_name
}

output "lambda_log_group" {
  description = "Nombre del grupo de logs de CloudWatch"
  value       = module.lambda_get_journal_data.log_group_name
}

# Pipeline outputs
output "pipeline_name" {
  description = "Nombre del pipeline"
  value       = module.pipeline_get_journal_data.pipeline_name
}

output "pipeline_arn" {
  description = "ARN del pipeline"
  value       = module.pipeline_get_journal_data.pipeline_arn
}

output "codebuild_project_name" {
  description = "Nombre del proyecto CodeBuild"
  value       = module.pipeline_get_journal_data.build_project_name
}

output "artifacts_bucket" {
  description = "Nombre del bucket de artefactos del pipeline"
  value       = module.pipeline_get_journal_data.artifacts_bucket
}

# ECR references
output "ecr_snapshots_url" {
  description = "URL del repositorio ECR de snapshots"
  value       = local.ecr_snapshots_url
}

output "ecr_releases_url" {
  description = "URL del repositorio ECR de releases"
  value       = local.ecr_releases_url
}

# Información útil para debugging
output "expected_resource_names" {
  description = "Nombres esperados de los recursos creados"
  value = {
    lambda_function = module.lambda_get_journal_data.function_name
    lambda_role     = module.lambda_get_journal_data.role_name
    pipeline        = module.pipeline_get_journal_data.pipeline_name
    codebuild       = module.pipeline_get_journal_data.build_project_name
  }
}