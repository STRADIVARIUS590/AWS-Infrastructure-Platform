terraform {
  required_version = ">= 1.9.0" # limita las versiones de Terraform.

  required_providers { # declara los proveedores necesarios.
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0 , < 7.0"
    }
  }
}

provider "aws" { # configura la conexión con AWS.
  region  = var.aws_region
  profile = var.aws_profile

  default_tags { # aplica etiquetas comunes a los recursos compatibles.
    tags = local.common_tags
  }
}
