# Configura el estado remoto. Esto debe ser aplicado ANTES que el resto.
# Terraform usará este bucket para guardar el archivo de estado (terraform.tfstate)
# y una tabla de DynamoDB para bloquear el estado y evitar conflictos.

terraform {
  backend "s3" {
    bucket         = "tf-state-personal-infra-main" # Debe ser creado manualmente antes
    key            = "global/terraform.tfstate"     # La ruta dentro del bucket
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-lock" # Debe ser creada manualmente antes
    encrypt        = true
  }
}