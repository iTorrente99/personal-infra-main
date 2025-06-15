# Infraestructura Serverless para "Personal App"

![Terraform](https://img.shields.io/badge/Terraform-%237B42BC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)

Este repositorio contiene la Infraestructura como Código (IaC) para una arquitectura de backend serverless en AWS. Utiliza **Terraform** para definir y gestionar un sistema de microservicios escalable, con un **pipeline de CI/CD completamente automatizado** para cada función.

## ✨ Visión General de la Arquitectura

El sistema está diseñado para que los desarrolladores puedan desplegar nuevas versiones de sus microservicios simplemente haciendo `git push`. Terraform se encarga de crear y mantener la infraestructura subyacente, mientras que AWS CodePipeline automatiza el ciclo de vida del despliegue del código.

### Flujo de Despliegue Automatizado

El proceso desde el código hasta el despliegue es el siguiente:

1.  **Commit a GitHub:** Un desarrollador sube cambios a un repositorio de un microservicio.
2.  **Activación del Pipeline:** **AWS CodePipeline** detecta el `push` y se activa automáticamente.
3.  **Construcción de la Imagen:** **AWS CodeBuild** toma el código fuente, construye una imagen Docker y la etiqueta con una versión.
4.  **Publicación en ECR:** La nueva imagen se sube a **Amazon ECR** (Elastic Container Registry).
5.  **Actualización de la Lambda:** CodeBuild actualiza la función **AWS Lambda** para que utilice la nueva imagen.
6.  **Disponibilidad en API Gateway:** La nueva versión de la Lambda está inmediatamente disponible a través de su endpoint en **API Gateway**.

```
+-------------------+      +----------------------+      +---------------------------+
|                   |      |                      |      |                           |
|  Desarrollador    +----->+  CI/CD (AWS)         +----->+  Infraestructura de App   |
|  (git push)       |      |                      |      |  (API Gateway -> Lambda)  |
|                   |      |                      |      |                           |
+-------------------+      +----------------------+      +---------------------------+
         |                          ^                              ^
         |                          |                              |
         +--------------------------+-----------> Terraform <-------+
                                    (Define y Gestiona Todo)
```

### Características Clave

*   **Infraestructura como Código:** Toda la infraestructura está definida en Terraform, garantizando consistencia, repetibilidad y control de versiones.
*   **CI/CD Automatizado:** Un pipeline por microservicio que se activa con cada `push` a la rama de desarrollo.
*   **Arquitectura Escalable:** Añadir un nuevo microservicio es tan simple como añadir unas pocas líneas de configuración en Terraform.
*   **Lambdas en Contenedores:** Las funciones Lambda se empaquetan como imágenes Docker, permitiendo entornos de ejecución personalizados y dependencias complejas.
*   **Aislamiento de Entornos:** Clara separación entre recursos `globales` (compartidos) y recursos de `entorno` (dev, prod).

## 🛠️ Stack Tecnológico

*   **Cloud Provider:** Amazon Web Services (AWS)
*   **Infraestructura como Código:** Terraform (v1.0+)
*   **CI/CD:** AWS CodePipeline, AWS CodeBuild, AWS CodeStar Connections
*   **Computación:** AWS Lambda (con imágenes Docker)
*   **Contenedores:** Docker, Amazon ECR
*   **API:** Amazon API Gateway
*   **Lenguaje de la App:** Python 3.11

## 📁 Estructura del Directorio

```
.
├── backend/                  # Código fuente de las funciones Lambda
│   └── lambdas/
│       └── lambda_.../       # Cada microservicio tiene su propia carpeta
├── infra/                    # Código de Terraform (IaC)
│   ├── global/               # Recursos globales (ej: ECR)
│   ├── environments/         # Configuraciones por entorno (dev, prod)
│   │   └── dev/
│   └── modules/              # Módulos de Terraform reutilizables
└── README.md
```

## 🚀 Guía de Inicio y Despliegue

Sigue estos pasos para desplegar la infraestructura completa desde cero.

### Prerrequisitos

Asegúrate de tener lo siguiente antes de empezar:

1.  Una **Cuenta de AWS** activa.
2.  **AWS CLI** [instalado y configurado](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) con credenciales de administrador.
3.  **Terraform CLI** (v1.0 o superior) [instalado](https://learn.hashicorp.com/tutorials/terraform/install-cli).
4.  **Docker Desktop** [instalado y en ejecución](https://www.docker.com/products/docker-desktop/).
5.  Una **Conexión de AWS CodeStar a GitHub** para que CodePipeline pueda acceder a los repositorios. [Sigue estas instrucciones](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-create-github.html).

### Paso 1: Configurar el Backend de Terraform

Terraform necesita un lugar para almacenar su estado de forma remota y segura.

```bash
# Nota: Los nombres de los buckets S3 son únicos a nivel mundial.
# Si el siguiente comando falla, reemplaza 'tf-state-personal-infra-main' por otro nombre único.
# La región 'eu-west-1' es consistente con la configuración del backend de Terraform.

# Crear el bucket S3 para el estado de Terraform
aws s3 mb s3://tf-state-personal-infra-main --region eu-west-1

# Crear la tabla DynamoDB para el bloqueo de estado
aws dynamodb create-table \
    --table-name terraform-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region eu-west-1
```

### Paso 2: Desplegar Recursos Globales (ECR)

Estos recursos se crean una sola vez y son compartidos por todos los entornos.

```bash
# 1. Navega al directorio de recursos ECR globales
cd infra/personal-infra-main/global/ecr

# 2. Inicializa Terraform
terraform init

# 3. Revisa y aplica los cambios
terraform plan
terraform apply --auto-approve
```

### Paso 3: Desplegar el Entorno de Desarrollo

Esto creará las Lambdas, Pipelines y el API Gateway para el entorno `dev`.

```bash
# 1. Navega al directorio del entorno
cd infra/personal-infra-main/environments/dev

# 2. (Recomendado) Crea un archivo 'terraform.tfvars' para tus variables locales.
#    Este archivo no debe ser subido al control de versiones (¡añádelo a .gitignore!).
#    Contendrá valores sensibles o específicos de tu entorno.
echo 'github_connection_arn = "arn:aws:codeconnections:eu-west-1:123456789012:connection/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"' > terraform.tfvars
echo "terraform.tfvars" >> .gitignore

# 3. Edita terraform.tfvars y reemplaza el ARN con el de tu conexión CodeStar real.

# 4. Inicializa Terraform
terraform init

# 5. Revisa y aplica los cambios
terraform plan
terraform apply --auto-approve
```

### Paso 4: Realizar el Primer Despliegue del Código

La infraestructura está lista. Sin embargo, la función Lambda se ha creado con una imagen de placeholder. Para desplegar el código real, simplemente haz tu primer `push` a la rama `dev` del repositorio de la Lambda (`iTorrente99/lambda_personal-app_get-journal-data`). Esto activará el pipeline y completará el ciclo.

## 💡 Flujo de Trabajo del Desarrollador: Añadir un Nuevo Microservicio

La arquitectura brilla por su facilidad para escalar. Sigue estos pasos para añadir un nuevo servicio:

1.  **Crea el Código:** Añade una nueva carpeta en `backend/lambdas/` para tu nuevo microservicio, incluyendo su `lambda_function.py`, `Dockerfile`, etc.
2.  **Crea un Repositorio en GitHub:** Crea un nuevo repositorio para alojar el código de este microservicio.
3.  **Declara el Servicio en Terraform:** Abre `infra/personal-infra-main/environments/dev/lambdas.tf` y añade una nueva entrada al mapa `lambdas_config`:

    ```terraform
    # infra/personal-infra-main/environments/dev/lambdas.tf

    locals {
      lambdas_config = {
        # ... (servicios existentes)

        # --- NUEVO SERVICIO AÑADIDO AQUÍ ---
        "process-payment" = {
          base_name   = "lambda_personal-app_process-payment"
          github_repo = "tu-usuario/lambda_personal-app_process-payment"
          timeout     = 30
          memory_size = 512
        }
      }
    }
    ```

4.  **Aplica los Cambios:** Desde `infra/personal-infra-main/environments/dev`, ejecuta `terraform apply`.
5.  **Despliega el Código:** Haz un `git push` a la rama `dev` del nuevo repositorio. El pipeline recién creado se activará y desplegará tu código.

## 🔮 Hoja de Ruta y Mejoras Futuras

-   [ ] **Seguridad de IAM:** Refinar las políticas de IAM en los módulos (especialmente `codebuild_policy`) para seguir el principio de mínimo privilegio.
-   [ ] **Pruebas Automatizadas:** Integrar etapas de `test` en `buildspec.yml` para ejecutar pruebas unitarias (`pytest`) y de `linting` (`flake8`).
-   [ ] **Gestión de Secretos:** Integrar **AWS Secrets Manager** para manejar credenciales de forma segura.
-   [ ] **Entorno de Producción:** Crear una nueva configuración en `environments/prod` que apunte a la rama `main` y utilice el repositorio ECR de `releases`.
-   [ ] **CORS Configurable:** Parameterizar la cabecera `Access-Control-Allow-Origin` en las Lambdas para que se pueda configurar por entorno.

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.