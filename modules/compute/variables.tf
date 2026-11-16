
variable "project_name" {
  description = "Project identifier"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "ami_id" {
  description = "Golden AMI ID built by Packer"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_ids" {
  description = "Private subnet IDs where EC2 instances will be deployed"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups attached to EC2 instances"
  type        = list(string)
}

variable "instance_profile_name" {
  description = "IAM instance profile attached to EC2 instances"
  type        = string
}

variable "target_group_arn" {
  description = "Application Load Balancer target group ARN"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
