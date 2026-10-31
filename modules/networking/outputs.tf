# expose the VPC identifier module to the parent module
output "vpc_id" {
    description = "ID of the main VPC"
    value = aws_vpc.main.id
}

# Expose the IPv4 CIDR assigned to the VPC
output "vpc_cidr_block" {
    description = "IPv4 CIDR block of the main VPC"
    value = aws.vpc.main.cidr_block
}

# expose the ID of the VPC's main route table
# we will use this configuration when configurating the network routing
output "main_route_table_id" {
    description = "ID od the main route table"
    value = aws_vpc.main.main_route_table_id
}