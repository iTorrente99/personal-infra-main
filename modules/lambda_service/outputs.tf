output "function_name" { value = module.lambda.function_name }
output "function_arn" { value = module.lambda.function_arn }
output "pipeline_name" { value = module.pipeline.pipeline_name }
output "invoke_arn" {
  description = "ARN de invocación de la función Lambda, usado por API Gateway"
  value       = module.lambda.invoke_arn
}