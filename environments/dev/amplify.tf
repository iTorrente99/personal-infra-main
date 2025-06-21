# Configuración de Amplify para el frontend en ambiente DEV

locals {
  # Build spec para Vite
  vite_build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - npm ci
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: dist
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT
}

# TEMPORAL: Crear la app sin repositorio para conectarlo manualmente después
module "amplify_frontend" {
  source = "../../modules/amplify"

  # Configuración básica
  app_name            = "${var.project_name}-frontend-${var.environment}"
  github_repository   = "https://github.com/iTorrente99/personal-app-frontend"
  github_access_token = "" # Vacío temporalmente
  branch_name         = var.frontend_branch_name
  stage               = var.environment == "dev" ? "DEVELOPMENT" : "PRODUCTION"
  framework           = "React"

  # Dominio personalizado (opcional)
  custom_domain       = var.frontend_custom_domain
  enable_www_redirect = true

  # Variables de entorno para el frontend
  environment_variables = {
    # URL de la API Gateway creada anteriormente
    VITE_API_URL = module.api_gateway.invoke_url
    # Puedes usar REACT_APP_ para Create React App o VITE_ para Vite
    VITE_ENV = var.environment
  }

  # Directorio de salida del build según el framework
  build_output_directory = var.frontend_framework == "nextjs" ? "out" : "dist"

  # Build spec personalizado
  build_spec = var.frontend_framework == "vite" ? local.vite_build_spec : null

  # Autenticación básica para entorno dev (opcional)
  enable_basic_auth      = false # var.environment == "dev" ? true : false
  basic_auth_credentials = var.environment == "dev" ? "admin:${var.frontend_basic_auth_password}" : ""

  common_tags = merge(
    local.common_tags,
    {
      Component = "Frontend"
      Framework = var.frontend_framework
    }
  )
}
