
variable "vpc_id" {
    description = "ID of the VPC where the ALB will be deployed"
    type = string
}

variable "public_subnet_a_id" {
    description = "ID of the first public subnet"
    type = string
}

variable "public_subnet_b_id" {
    description = "ID of the second public subnet"
    type = string
}

variable "alb_security_group_id" {
    description = "ID of the ALB security group"
    type = string
}
