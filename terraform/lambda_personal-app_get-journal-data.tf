# --- Rol de IAM para la Lambda 'lambda_personal-app_get-journal-data' ---
resource "aws_iam_role" "lambda_personal-app_get-journal-data_role" {
  name               = "lambda_personal-app_get-journal-data_role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_personal-app_get-journal-data_policy" {
  role       = aws_iam_role.lambda_personal-app_get-journal-data_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# --- Función Lambda: lambda_personal-app_get-journal-data (para el entorno DEV) ---
resource "aws_lambda_function" "lambda_personal-app_get-journal-data_dev" {
  function_name = "lambda_personal-app_get-journal-data_dev"
  role          = aws_iam_role.lambda_personal-app_get-journal-data_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.snapshots.repository_url}:initial"
  timeout       = 30
  memory_size   = 128
}

# --- Pipeline de CI/CD para la Lambda ---

# 1. Roles para Pipeline y Build
resource "aws_iam_role" "codepipeline_role" {
  name               = "lambda_personal-app_get-journal-data_codepipeline-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "codepipeline.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role" "codebuild_role" {
  name               = "lambda_personal-app_get-journal-data_codebuild-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "codebuild.amazonaws.com" }
    }]
  })
}

# 2. Política de Permisos para los Roles
resource "aws_iam_policy" "pipeline_policy" {
  name = "lambda_personal-app_get-journal-data_pipeline-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["codestar-connections:UseConnection"],
        Resource = "arn:aws:codeconnections:eu-west-1:590184031333:connection/7206e653-7f3b-4ca8-bbb3-8ff36867cffa"
      },
      # Permisos para que CodeBuild pueda subir imágenes a AMBOS ECRs
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ],
        Resource = "*"
      },
      # Permisos para escribir logs
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      # Permisos para que CodePipeline actualice la Lambda
      {
        Effect   = "Allow",
        Action   = ["lambda:UpdateFunctionCode"],
        Resource = aws_lambda_function.lambda_personal-app_get-journal-data_dev.arn
      }
    ]
  })
}

# 3. Asignación de Políticas
resource "aws_iam_role_policy_attachment" "codepipeline_policy_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.pipeline_policy.arn
}
resource "aws_iam_role_policy_attachment" "codebuild_policy_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.pipeline_policy.arn
}

# 4. El Pipeline en sí
resource "aws_codepipeline" "lambda_personal-app_get-journal-data_pipeline_dev" {
  name     = "lambda_personal-app_get-journal-data_dev-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline_artifacts.bucket
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS" # Cambiado a "AWS", que es lo correcto para CodeStarSourceConnection
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = "arn:aws:codeconnections:eu-west-1:590184031333:connection/7206e653-7f3b-4ca8-bbb3-8ff36867cffa"
        FullRepositoryId = "iTorrente99/lambda_personal-app_get-journal-data"
        BranchName       = "dev"
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
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.lambda_personal-app_get-journal-data_build.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "DeployToLambda"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "Lambda"
      version         = "1"
      input_artifacts = ["build_output"] # CORREGIDO
      configuration = {
        FunctionName = aws_lambda_function.lambda_personal-app_get-journal-data_dev.function_name
        # Línea de ImageURI eliminada
      }
    }
  }
}

# 5. El proyecto de CodeBuild (con buildspec incrustado)
resource "aws_codebuild_project" "lambda_personal-app_get-journal-data_build" {
  name          = "lambda_personal-app_get-journal-data-build"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = "15"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
    environment_variable {
      name  = "ECR_REPO_SNAPSHOTS"
      value = aws_ecr_repository.snapshots.repository_url
    }
    environment_variable {
      name  = "AWS_REGION"
      value = data.aws_region.current.name
    }
    # Añadimos una variable de entorno para el nombre de la función Lambda
    environment_variable {
      name = "LAMBDA_FUNCTION_NAME"
      value = aws_lambda_function.lambda_personal-app_get-journal-data_dev.function_name
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = <<-EOT
      version: 0.2
      phases:
        pre_build:
          command:
            - echo "Iniciando sesión en Amazon ECR..."
            - aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO_SNAPSHOTS
            - export IMAGE_TAG=dev-$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
        build:
          commands:
            - echo "Construyendo la imagen Docker con la etiqueta $IMAGE_TAG..."
            - docker build -t $ECR_REPO_SNAPSHOTS:$IMAGE_TAG .
        post_build:
          commands:
            - echo "Subiendo la imagen a ECR..."
            - docker push $ECR_REPO_SNAPSHOTS:$IMAGE_TAG
            - echo "Creando el archivo de definición de imagen para el despliegue..."
            - printf '[{"name":"%s","imageUri":"%s"}]' "$LAMBDA_FUNCTION_NAME" "$ECR_REPO_SNAPSHOTS:$IMAGE_TAG" > imagedefinitions.json
      artifacts:
        files:
          - imagedefinitions.json
    EOT
  }
}

# 6. Bucket S3 para los artefactos del pipeline
resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "codepipeline-artifacts-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}