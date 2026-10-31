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


# Defines the CIDR range used by the development environment.
variable "vpc_cidr" {
  description = "IPv4 CIDR block for the development VPC"
  type        = string
  default     = "10.0.0.0/16"
}