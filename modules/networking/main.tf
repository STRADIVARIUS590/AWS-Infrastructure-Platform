
# Create the main virtual network for our AWS infrastructure.
resource "aws_vpc" "main" {

  # Defines the private IPv4 address range available inside the VPC.
  cidr_block = var.vpc_cidr

  # Allows resources inside the VPC to resolve AWS-provided DNS names.
  enable_dns_support = true

  # Assigns DNS hostnames to instances launched inside the VPC.
  enable_dns_hostnames = true

  # Tags help identify and organize AWS resources.
  tags = {
    Name        = "aws-infrastructure-platform-dev-vpc"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Think of it as the connection point between your VPC and the public internet.

# However, attaching an IGW does not automatically give your subnets internet access.
# create itnernet gateway for our VPC
resource "aws_internet_gateway" "main" {
  # attach our current gateway to our existing VPC
  # terrafor infers the dependency from the reference
  vpc_id = aws_vpc.main.id

   # Identify this resource in AWS.
  tags = {
    Name        = "aws-infrastructure-platform-dev-igw"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}


# create a dedicated route table for public subnets
# A route table contains rules that determine where network traffic goes.

#Our VPC already has a main route table, automatically created by AWS
#. We're creating a separate one because we want explicit control over public subnet traffic.
resource "aws_route_table" "public" {

  # associate this route table with our VPC 
  vpc_id = aws_vpc.main.id

  # identify this route table in aws
  tags = {
    Name = "aws-infrastructure-platform-public-dev-rt"
    Environment = "dev"
    ManagedBy = "Terraform"
    Tier = "public"
  }
}

# Route public sibnet internet-bound traffic trough the internet gateway
resource "aws_route" "public_internet" {
  # use our dedicated public route table
  route_table_id = aws_route_table.public.id

  # match all ipv4 destinations
  destination_cidr_block = "0.0.0.0/0" # Matches every IPv4 destination. This is the default route.

  # send matching traffc to our internet gateway
  gateway_id = aws_internet_gateway.main.id # Identifies the Internet Gateway that receives the traffic.
}


# provivate route table for private subnets

# Why do we need a separate route table?
# Our public route table contains:
# 0.0.0.0/0 → Internet Gateway


# We don't want our backend subnets to inherit that direct internet route.
resource "aws_route_table" "private" {
  # associate this route table with our existing VPC 
  vpc_id = aws_vpc.main.id

  # Identify this route table in AWS.
  tags = {
    Name        = "aws-infrastructure-platform-private-dev-rt"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Tier        = "private"
  }
}

