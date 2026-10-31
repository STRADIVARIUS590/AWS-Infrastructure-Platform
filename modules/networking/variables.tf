# define the IPV4 address range  allocated for this VPC
# the calling environment can override this default
variable "vpc_cidr" {
    description = "IPv4 CIDR block for the VPC"
    type = string
    default = "10.0.0.0/16"


    # cidrnetmask()	Converts a CIDR prefix into its subnet mask; fails for invalid CIDR input
    # can()	Returns true if an expression can be evaluated without an error
    validation {
        condition = can(cidrnetmask(var.vpc_cidr))
        error_message = "The VPC CIDR value must contain a valid block"
    }
}