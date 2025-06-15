# environments/dev/main.tf
# Definición de recursos para el ambiente DEV

# Lambda function para get-journal-data
module "lambda_get_journal_data" {
  source = "../../modules/lambda"
  
  function_base_name = local.lambda_base_name
  environment        = var.environment
  
  # Usar una imagen temporal base de Python 3.11
  # El pipeline actualizará esto automáticamente en el primer despliegue
  image_uri = "${local.ecr_snapshots_url}:initial"
  
  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size
  
  environment_variables = {
    LOG_LEVEL   = "INFO"
    ENVIRONMENT = var.environment
  }
  
  log_retention_days = 7
  common_tags        = local.common_tags
}

# Pipeline CI/CD para la Lambda
module "pipeline_get_journal_data" {
  source = "../../modules/pipeline"
  
  pipeline_name = local.lambda_base_name
  environment   = var.environment
  
  # Configuración de GitHub
  github_connection_arn = var.github_connection_arn
  github_repository     = var.github_repository
  github_branch         = var.github_branch
  
  # Configuración de ECR y Lambda
  ecr_repository_url   = local.ecr_snapshots_url
  lambda_function_name = module.lambda_get_journal_data.function_name
  lambda_function_arn  = module.lambda_get_journal_data.function_arn
  
  # Configuración de build
  build_compute_type = "BUILD_GENERAL1_SMALL"
  build_image        = "aws/codebuild/standard:5.0"
  buildspec_content  = data.local_file.buildspec.content
  
  # Variables de entorno adicionales para el build
  build_environment_variables = {
    ECR_REPO_SNAPSHOTS = local.ecr_snapshots_url
    LAMBDA_NAME_PREFIX = local.lambda_base_name
  }
  
  common_tags = local.common_tags
}