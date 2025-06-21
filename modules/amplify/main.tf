# Módulo para crear aplicaciones Amplify con dominio personalizado

# Data source para obtener el branch actual si necesitamos info adicional
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Rol IAM para Amplify
resource "aws_iam_role" "amplify_role" {
  name = "${var.app_name}-amplify-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "amplify.amazonaws.com"
      }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "amplify_policy" {
  name = "${var.app_name}-amplify-policy"
  role = aws_iam_role.amplify_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream", 
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::amplify-*",
          "arn:aws:s3:::amplify-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudformation:CreateStack",
          "cloudformation:UpdateStack",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeStacks",
          "cloudformation:DescribeStackEvents",
          "cloudformation:DescribeStackResources",
          "cloudformation:GetTemplate",
          "cloudformation:ValidateTemplate"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "cloudformation.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Alternativamente, adjuntar la política administrada de AWS
resource "aws_iam_role_policy_attachment" "amplify_backend_role" {
  role       = aws_iam_role.amplify_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-Amplify"
}

# Crear la aplicación Amplify
resource "aws_amplify_app" "app" {
  name                     = var.app_name
  # Repository se configurará manualmente después via OAuth
  repository               = var.github_repository != "" ? var.github_repository : null
  enable_branch_auto_build = true
  iam_service_role_arn    = aws_iam_role.amplify_role.arn
  
  # Si tienes un access token temporal, úsalo (aunque está deprecado)
  # De lo contrario, conectaremos manualmente después
  access_token             = var.github_access_token != "" ? var.github_access_token : null
  
  # Configuración de build
  build_spec = var.build_spec != null ? var.build_spec : <<-EOT
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
        baseDirectory: ${var.build_output_directory}
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  # Variables de entorno
  environment_variables = merge(
    {
      AMPLIFY_DIFF_DEPLOY = "false"
      _LIVE_UPDATES       = "[{\"pkg\":\"node\",\"type\":\"nvm\",\"version\":\"18\"}]"
    },
    var.environment_variables
  )

  # Regla por defecto para SPA (React Router, Vue Router, etc.)
  custom_rule {
    source = "</^[^.]+$|\\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|woff2|ttf|map|json)$)([^.]+$)/>"
    target = "/index.html"
    status = "200"
  }

  # Reglas de redirección personalizadas adicionales
  dynamic "custom_rule" {
    for_each = var.custom_rules
    content {
      source = custom_rule.value.source
      target = custom_rule.value.target
      status = custom_rule.value.status
    }
  }

  tags = var.common_tags
}

# Crear el branch principal (solo si hay repositorio)
resource "aws_amplify_branch" "main" {
  count = var.github_repository != "" ? 1 : 0
  
  app_id              = aws_amplify_app.app.id
  branch_name         = var.branch_name
  stage              = var.stage
  enable_auto_build  = true
  
  framework          = var.framework
  
  environment_variables = var.branch_environment_variables

  # Autenticación básica opcional
  enable_basic_auth      = var.enable_basic_auth
  basic_auth_credentials = var.enable_basic_auth ? base64encode(var.basic_auth_credentials) : null

  tags = var.common_tags
}

# Configurar el dominio personalizado
resource "aws_amplify_domain_association" "domain" {
  count = var.custom_domain != null && var.github_repository != "" ? 1 : 0
  
  app_id      = aws_amplify_app.app.id
  domain_name = var.custom_domain
  
  # Configuración de subdominios
  dynamic "sub_domain" {
    for_each = var.subdomains
    content {
      branch_name = sub_domain.value.branch_name
      prefix      = sub_domain.value.prefix
    }
  }
  
  # Si no se especifican subdominios, usar configuración por defecto
  dynamic "sub_domain" {
    for_each = length(var.subdomains) == 0 ? [1] : []
    content {
      branch_name = var.branch_name
      prefix      = ""
    }
  }
  
  # www redirect si está habilitado
  dynamic "sub_domain" {
    for_each = var.enable_www_redirect && length(var.subdomains) == 0 ? [1] : []
    content {
      branch_name = var.branch_name
      prefix      = "www"
    }
  }
}