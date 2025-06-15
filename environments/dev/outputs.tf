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