

variable "vpc_id" {
  description = "IP of the VPC where the security groups will be created"
  type        = string
}

variable "application_port" {
  description = "port used by backend application instances"
  type        = number
  default     = 8080
}

variable "database_port" {
  description = "Port used by the database engine"
  type        = number
  default     = 5432 # PostgreSQL
}

