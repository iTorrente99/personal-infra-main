# Outputs del módulo Lambda

output "function_name" {
  description = "Nombre de la función Lambda"
  value       = aws_lambda_function.function.function_name
}

output "function_arn" {
  description = "ARN de la función Lambda"
  value       = aws_lambda_function.function.arn
}

output "invoke_arn" {
  description = "ARN de invocación de la función Lambda"
  value       = aws_lambda_function.function.invoke_arn
}

output "role_arn" {
  description = "ARN del rol IAM de la Lambda"
  value       = aws_iam_role.lambda_role.arn
}

output "role_name" {
  description = "Nombre del rol IAM de la Lambda"
  value       = aws_iam_role.lambda_role.name
}

output "log_group_name" {
  description = "Nombre del grupo de logs de CloudWatch"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}