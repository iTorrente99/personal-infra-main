# infra/personal-infra-main/modules/api_gateway/outputs.tf

output "invoke_url" {
  description = "La URL base para invocar la API en este stage"
  value       = aws_api_gateway_stage.stage.invoke_url
}

output "api_id" {
  description = "El ID de la API Gateway"
  value       = aws_api_gateway_rest_api.api.id
}