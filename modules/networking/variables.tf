# define the IPV4 address range  allocated for this VPC
# the calling environment can override this default
variable "vpc_cidr" {
    description = "IPv4 CIDR block for the VPC"
    type = string
    default = "10.0.0.0/16"
}