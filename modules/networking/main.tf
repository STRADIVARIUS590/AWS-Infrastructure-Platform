
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