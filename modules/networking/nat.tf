# allocate a public IPv4 address for the NAT gateway
resource "aws_eip" "nat" {
    # create one elasti IP when NAT is enabled
    count = var.enable_nat_gateway ? 1 : 0

    # allocate this elastic IP for use within a VPC
    domain = "vpc"

    # identify the elastic IP in AWS
    tags = {
        Name = "aws-infrastructure-platform-dev-nat-eip"
        Environment = "dev"
        ManagedBy = "Terraform"
    }
}

# create a NAT gateway  for outbound internet connectivity
resource "aws_nat_gateway" "main" {
    # create one NAT gateway when is enabled, none otherwise
    count = var.enable_nat_gateway ? 1 : 0

    # use the Elastic IP allocated specificaliy for this NAT gateway
    allocation_id = aws_eip.nat[0].id

    # place the NAT gateway in the public A subnet
    subnet_id = aws_subnet.public_a.id

    # identify the NAT gateway in AWS


    tags = {
        Name        = "aws-infrastructure-platform-dev-nat"
        Environment = "dev"
        ManagedBy   = "Terraform"
    }

    # ensure the internet gateway exists before creating the NAT gateway
    depends_on = [ aws_internet_gateway.main ]
}


# route the internet bound traffic from provate subnets to trough the NAT gateway
resource "aws_route" "private_nat" {
    # create this route only when NAT is enabled
    count = var.enable_nat_gateway ? 1 : 0

    # use the private route table
    route_table_id = aws_route_table.private.id

    # match all IPv4 dstinations outside more specific routes
    destination_cidr_block = "0.0.0.0/0"

    # forward traffic to our NAT gateway
    nat_gateway_id = aws_nat_gateway.main[0].id
}