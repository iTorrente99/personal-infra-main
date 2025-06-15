# Módulo reutilizable para crear funciones Lambda

# Data source para obtener la región actual
data "aws_region" "current" {}

# Rol IAM para la Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_base_name}_${var.environment}_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  
  tags = var.common_tags
}

# Política básica de ejecución
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Políticas adicionales (si se proporcionan)
resource "aws_iam_role_policy_attachment" "additional_policies" {
  for_each = toset(var.additional_policy_arns)
  
  role       = aws_iam_role.lambda_role.name
  policy_arn = each.value
}

# Política inline personalizada (si se proporciona)
resource "aws_iam_role_policy" "inline_policy" {
  count = var.inline_policy != null ? 1 : 0
  
  name   = "${var.function_base_name}_${var.environment}_inline_policy"
  role   = aws_iam_role.lambda_role.id
  policy = var.inline_policy
}

# Función Lambda
resource "aws_lambda_function" "function" {
  function_name = "${var.function_base_name}_${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  
  package_type = "Image"
  image_uri    = var.image_uri
  
  timeout     = var.timeout
  memory_size = var.memory_size
  
  environment {
    variables = merge(
      {
        ENVIRONMENT = var.environment
        REGION      = data.aws_region.current.name
      },
      var.environment_variables
    )
  }
  
  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Function    = var.function_base_name
    }
  )
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.function.function_name}"
  retention_in_days = var.log_retention_days
  
  tags = var.common_tags
}