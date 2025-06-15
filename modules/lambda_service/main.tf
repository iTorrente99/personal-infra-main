# 1. Recurso Lambda
module "lambda" {
  source = "../lambda" # Llama a tu módulo lambda existente

  function_base_name  = var.function_base_name
  environment         = var.environment
  image_uri           = "${var.ecr_snapshots_url}:initial" # Imagen inicial
  ecr_repository_name = var.ecr_snapshots_name
  timeout             = var.lambda_timeout
  memory_size         = var.lambda_memory_size
  common_tags         = var.common_tags
}

# 2. Recurso Pipeline
module "pipeline" {
  source = "../pipeline" # Llama a tu módulo pipeline existente

  pipeline_name         = var.function_base_name # El pipeline se llama como la lambda
  environment           = var.environment
  github_connection_arn = var.github_connection_arn
  github_repository     = var.github_repository
  github_branch         = var.github_branch
  ecr_repository_url    = var.ecr_snapshots_url
  lambda_function_name  = module.lambda.function_name
  lambda_function_arn   = module.lambda.function_arn
  buildspec_content     = data.local_file.buildspec.content # Leemos el buildspec

  build_environment_variables = {
    ECR_REPO_SNAPSHOTS = var.ecr_snapshots_url
    LAMBDA_NAME_PREFIX = var.function_base_name
  }
  common_tags = var.common_tags
}

# Data source para leer el buildspec (necesario aquí)
data "local_file" "buildspec" {
  filename = var.buildspec_path
}
