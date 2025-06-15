# Outputs del módulo Pipeline

output "pipeline_name" {
  description = "Nombre del pipeline"
  value       = aws_codepipeline.pipeline.name
}

output "pipeline_arn" {
  description = "ARN del pipeline"
  value       = aws_codepipeline.pipeline.arn
}

output "build_project_name" {
  description = "Nombre del proyecto CodeBuild"
  value       = aws_codebuild_project.build_project.name
}

output "artifacts_bucket" {
  description = "Nombre del bucket de artefactos"
  value       = aws_s3_bucket.pipeline_artifacts.id
}

output "codepipeline_role_arn" {
  description = "ARN del rol de CodePipeline"
  value       = aws_iam_role.codepipeline_role.arn
}

output "codebuild_role_arn" {
  description = "ARN del rol de CodeBuild"
  value       = aws_iam_role.codebuild_role.arn
}