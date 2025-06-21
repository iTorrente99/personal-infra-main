# infra/personal-infra-main/environments/dev/outputs.tf

output "deployed_lambda_services" {
  description = "Mapa con los detalles de cada servicio Lambda desplegado"
  value = {
    for key, service in module.lambda_service : key => {
      lambda_name   = service.function_name
      lambda_arn    = service.function_arn
      pipeline_name = service.pipeline_name
    }
  }
}

output "ecr_snapshots_url" {
  description = "URL del repositorio ECR de snapshots para este entorno"
  value       = local.ecr_snapshots_url
}

output "api_invoke_url" {
  description = "URL base de la API REST para este entorno"
  value       = module.api_gateway.invoke_url
}

# ===== OUTPUTS DE AMPLIFY (FRONTEND) =====

output "frontend_app_url" {
  description = "URL de la aplicación frontend en Amplify"
  value       = module.amplify_frontend.branch_url
}

output "frontend_custom_domain_url" {
  description = "URL del dominio personalizado del frontend (si está configurado)"
  value       = module.amplify_frontend.custom_domain_url
}

output "frontend_app_id" {
  description = "ID de la aplicación Amplify"
  value       = module.amplify_frontend.app_id
}

output "frontend_dns_verification" {
  description = "Registros DNS necesarios para verificar el dominio personalizado"
  value       = module.amplify_frontend.custom_domain_verification_records
}

# Output combinado con toda la info de acceso
output "application_urls" {
  description = "URLs de acceso a la aplicación"
  value = {
    frontend_amplify = module.amplify_frontend.branch_url
    frontend_custom  = module.amplify_frontend.custom_domain_url
    api_gateway      = module.api_gateway.invoke_url
    
    endpoints = {
      for key, config in local.lambdas_config : key => "${module.api_gateway.invoke_url}/${key}"
    }
  }
}