# Outputs del módulo Amplify

output "app_id" {
  description = "ID de la aplicación Amplify"
  value       = aws_amplify_app.app.id
}

output "app_arn" {
  description = "ARN de la aplicación Amplify"
  value       = aws_amplify_app.app.arn
}

output "default_domain" {
  description = "Dominio por defecto de Amplify"
  value       = aws_amplify_app.app.default_domain
}

output "branch_url" {
  description = "URL del branch desplegado (vacío si no hay branch)"
  value       = var.github_repository != "" ? "https://${var.branch_name}.${aws_amplify_app.app.default_domain}" : "Conecta el repositorio en la consola de Amplify"
}

output "custom_domain_url" {
  description = "URL del dominio personalizado (si está configurado)"
  value       = var.custom_domain != null ? "https://${var.custom_domain}" : null
}

output "custom_domain_verification_records" {
  description = "Registros DNS necesarios para verificar el dominio personalizado"
  value = var.custom_domain != null && length(aws_amplify_domain_association.domain) > 0 ? {
    instructions = "Añade estos registros CNAME en tu proveedor DNS"
    records      = try(aws_amplify_domain_association.domain[0].certificate_verification_dns_record, null)
  } : null
}