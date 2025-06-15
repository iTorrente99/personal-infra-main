locals {
  # Mapa de configuración para todas las lambdas del entorno DEV
  lambdas_config = {
    "get-journal-data" = {
      # El nombre base que coincide con el repo y la función
      base_name = "lambda_personal-app_get-journal-data"
      # El repo específico para esta lambda
      github_repo = "iTorrente99/lambda_personal-app_get-journal-data"
      # Parámetros opcionales que sobreescriben los defaults
      timeout     = 15
      memory_size = 256
    }
    # --- AQUÍ AÑADIRÁS TUS FUTURAS LAMBDAS ---
    # "process_payment" = {
    #   base_name       = "lambda_personal-app_process-payment"
    #   github_repo     = "iTorrente99/lambda_personal-app_process-payment"
    #   timeout         = 30
    #   memory_size     = 512
    # }
  }
}
