
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