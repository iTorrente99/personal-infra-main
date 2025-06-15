# 1. Crear la API REST principal
resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = "API para el proyecto ${var.api_name} en el entorno ${var.environment}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.common_tags
}

# 2. Crear un recurso (endpoint path) para CADA lambda dinámicamente
resource "aws_api_gateway_resource" "resource" {
  for_each = var.lambda_integrations

  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = each.key # la clave del mapa será el path, ej: "get-journal-data"
}

# 3. Crear un método "ANY" para cada recurso (para permitir GET, POST, etc.)
resource "aws_api_gateway_method" "method" {
  for_each = aws_api_gateway_resource.resource

  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = each.value.id
  http_method   = "ANY"
  authorization = "NONE" # Pública por ahora
}

# 4. Crear la integración entre el método y la Lambda (tipo AWS_PROXY)
resource "aws_api_gateway_integration" "integration" {
  for_each = var.lambda_integrations

  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource[each.key].id
  http_method             = aws_api_gateway_method.method[each.key].http_method
  integration_http_method = "POST" # La invocación de Lambda siempre es POST
  type                    = "AWS_PROXY"
  uri                     = each.value.lambda_invoke_arn
}

# 5. Permiso para que API Gateway pueda invocar cada Lambda
resource "aws_lambda_permission" "apigw_permission" {
  for_each = var.lambda_integrations

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_arn
  principal     = "apigateway.amazonaws.com"

  # Restringir el permiso solo a esta API y a este recurso específico
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.method[each.key].http_method}${aws_api_gateway_resource.resource[each.key].path}"
}

# 6. Despliegue de la API (importante el trigger para que se redespliegue al cambiar)
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(
      concat(
        [for res in aws_api_gateway_resource.resource : res.id],
        [for meth in aws_api_gateway_method.method : meth.id],
        [for integ in aws_api_gateway_integration.integration : integ.id]
      )
    ))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 7. Crear el stage del despliegue (ej: /dev, /pre)
resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.environment

  tags = var.common_tags
}
