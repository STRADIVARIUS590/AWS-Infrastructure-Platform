locals {
  project_name = var.project_name
  environment  = var.envionment

  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }

  name_prefix = "${local.project_name}-${local.environment}"
}