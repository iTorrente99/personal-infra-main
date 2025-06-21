locals {
  # Mapa de configuración para todas las lambdas del entorno DEV
  lambdas_config = {
    "get-journal-data" = {
      # El nombre base que coincide con el repo y la función
      base_name = "lambda_personal-app_get-journal-data"
      # El repo específico para esta lambda
      github_repo = var.github_repository_lambda_get_journal_data
      # Parámetros opcionales que sobreescriben los defaults
      timeout     = 15
      memory_size = 256
    }
  }
}
