variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-2"
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "aws-real"
}

variable "envionment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project identifier"
  type        = string
  default     = "aws-infraestructure-platform"
}