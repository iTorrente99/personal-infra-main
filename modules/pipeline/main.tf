# modules/pipeline/main.tf
# Módulo para crear pipelines CI/CD (VERSIÓN CORREGIDA CON POLÍTICAS SEPARADAS)

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# S3 Bucket para artefactos del pipeline
resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "codepipeline-artifacts-${data.aws_caller_identity.current.account_id}-${var.environment}"

  tags = merge(
    var.common_tags,
    {
      Purpose = "Pipeline artifacts storage"
    }
  )
}

resource "aws_s3_bucket_versioning" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Rol IAM para CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  name = "${var.pipeline_name}_${var.environment}_codepipeline_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
    }]
  })

  tags = var.common_tags
}

# Rol IAM para CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "${var.pipeline_name}_${var.environment}_codebuild_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
    }]
  })

  tags = var.common_tags
}

# Política para el rol de CodePipeline
resource "aws_iam_policy" "codepipeline_policy" {
  name = "${var.pipeline_name}_${var.environment}_codepipeline_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.pipeline_artifacts.arn,
          "${aws_s3_bucket.pipeline_artifacts.arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "codebuild:StartBuild",
          "codebuild:StopBuild",
          "codebuild:BatchGetBuilds",
          "codebuild:ListBuildsForProject"
        ]
        Resource = aws_codebuild_project.build_project.arn
      },
      {
        Effect   = "Allow"
        Action   = ["codestar-connections:UseConnection"]
        Resource = var.github_connection_arn
      }
    ]
  })
}

# Política para el rol de CodeBuild
resource "aws_iam_policy" "codebuild_policy" {
  name = "${var.pipeline_name}_${var.environment}_codebuild_policy"

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
        # Es común permitir esto en todos los logs para simplicidad
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.pipeline_artifacts.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        # Idealmente, esto se restringiría al ARN del repositorio ECR específico
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["lambda:UpdateFunctionCode"],
        Resource = var.lambda_function_arn
      }
    ]
  })
}

# Adjuntar políticas a los roles
resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

# Proyecto CodeBuild
resource "aws_codebuild_project" "build_project" {
  name         = "${var.pipeline_name}_${var.environment}_build"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.build_compute_type
    image                       = var.build_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "ECR_REPO_URL"
      value = var.ecr_repository_url
    }

    environment_variable {
      name  = "AWS_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "LAMBDA_FUNCTION_NAME"
      value = var.lambda_function_name
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }

    # Variables adicionales del usuario
    dynamic "environment_variable" {
      for_each = var.build_environment_variables
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_content
  }

  tags = var.common_tags
}

# Pipeline
resource "aws_codepipeline" "pipeline" {
  name     = "${var.pipeline_name}_${var.environment}_pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.pipeline_artifacts.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = var.github_repository
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      # No se necesitan artefactos de salida si el deploy se hace en el mismo paso
      # output_artifacts = ["build_output"] 

      configuration = {
        ProjectName = aws_codebuild_project.build_project.name
      }
    }
  }

  tags = var.common_tags
}