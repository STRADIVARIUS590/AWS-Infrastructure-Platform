output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "aws_region" {
  description = "AWS region where Terraform is operating"
  value       = data.aws_region.current.region
}

output "availability_zones" {
  description = "Available Availability Zones in the current region"
  value       = data.aws_availability_zones.available.names
}

output "common_tags" {
  value = local.common_tags
}