
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
