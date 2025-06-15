# Definición DINÁMICA de recursos para el ambiente DEV

# Bucle que crea la Lambda y su Pipeline para cada entrada en lambdas_config
module "lambda_service" {
  for_each = local.lambdas_config # ¡La magia está aquí!

  source = "../../modules/lambda_service" # Crearemos este nuevo módulo en el siguiente paso

  # Parámetros generales del entorno
  environment           = var.environment
  github_connection_arn = var.github_connection_arn
  github_branch         = var.github_branch # Asumimos que la rama es la misma para todas las lambdas del entorno
  common_tags           = local.common_tags
  ecr_snapshots_url     = local.ecr_snapshots_url
  ecr_snapshots_name    = data.terraform_remote_state.global_ecr.outputs.snapshots_repository_name

  # Parámetros específicos de cada lambda, leídos del bucle
  function_base_name    = each.value.base_name
  github_repository     = each.value.github_repo
  
  # Usar valores específicos si existen, si no, los defaults del entorno
  lambda_timeout        = lookup(each.value, "timeout", var.lambda_timeout)
  lambda_memory_size    = lookup(each.value, "memory_size", var.lambda_memory_size)
}

module "api_gateway" {
  source = "../../modules/api_gateway"

  api_name    = "${var.project_name}-api" # ej: personal-app-api
  environment = var.environment          # ej: dev
  common_tags = local.common_tags

  # Construimos el mapa de integraciones dinámicamente a partir de nuestras lambdas
  lambda_integrations = {
    for key, config in local.lambdas_config : key => {
      lambda_invoke_arn   = module.lambda_service[key].invoke_arn
      lambda_function_arn = module.lambda_service[key].function_arn
    }
  }
}