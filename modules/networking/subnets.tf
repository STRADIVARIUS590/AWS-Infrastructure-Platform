# create the first úblic subnet iside our VPC

resource "aws_subnet" "public_a" {
    # associate the subnet with our existing VPC
    # terraform automantically infers the dependency 
    vpc_id = aws_vpc.main.id #  We're referencing the VPC created in main.tf.


    # calculate the subnet CIDR from the VPC's CIDR
    # 16 + 8 additional bits = /24
    # the index 1 generates  10.0.1.0/24
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 1)
    
    # place this subnet in the fist availability zone
    availability_zone = "us-east-2a"

    # automatically assign public IPv4 address to
    # network interface launched in this subnet
    map_public_ip_on_launch = true

    # identify the subnet in AWS 
    tags = {
        Name = "aws-infrastructure-platform-public-dev-a"
        Environment = "dev"
        ManagedBy = "Terraform"
        Tier = "public"
    }
}



# create the second public subnet in a different AZ 
resource "aws_subnet" "public_b" {
    # associante our subnet with our sxisting VPC
    vpc_id = aws_vpc.main.id 

    # generate the second /24 subnet from our VPC CIDR
    # the index 2 produces 10.0.2.0/24
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 2)

    # place this subnet in the second AZ
    availability_zone = "us-east-2b"

    # automatically assigns a public IPv4 address to 
    # eligible network interfaces launched in this subnet
    map_public_ip_on_launch = true

    tags = {
        Name = "aws-infrastructure-platform-public-dev-b"
        Environment = "dev"
        ManagedBy = "Terraform"
        Tier = "public"
    
    }
}




############PRIVATE SUBNETS###############

# create our first private subnet for backend workloads
resource "aws_subnet" "private_a" {
    vpc_id = aws_vpc.main.id

    # generate the 10.0.11.0/24 cidr block
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 11)

    # place the subnet in the first availability zone
    availability_zone = "us-east-2a"

    #  do not automatically assign the public IPv4 address
    
    map_public_ip_on_launch = false # this doesn't, by itself, make a subnet private. We'll establish its private status through routing configuration later.

    # identify this subnet as private

    tags = {
        Name = "aws-infrastructure-platform-private-dev-a"
        Environment = "dev"
        ManagedBy = "Terraform"
        Tier = "private"
    }
}

# Create the second private subnet in Availability Zone B.
resource "aws_subnet" "private_b" {
  # Place this subnet inside our main VPC.
  vpc_id = aws_vpc.main.id

  # Allocate the 10.0.12.0/24 address range.
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 12)

  # Place the subnet in the second Availability Zone.
  availability_zone = "us-east-2b"

  # Do not automatically assign public IPv4 addresses.
  map_public_ip_on_launch = false

    tags = {
        Name        = "aws-infrastructure-platform-private-dev-b"
        Environment = "dev"
        ManagedBy   = "Terraform"
        Tier        = "private"
    }
}


###########DATABASE SUBNETS###############
# create the first database subnet in Availability zone A
resource "aws_subnet" "database_a" {
    vpc_id = aws_vpc.main.id

    # generate 10.0.21.0/24 from the VPC CIDR
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 21)

    # place the subnet in the first availability zone
    availability_zone = "us-east-2a"

    map_public_ip_on_launch = false

      # Identify this subnet as part of the database tier.
    tags = {
        Name        = "aws-infrastructure-platform-database-dev-a"
        Environment = "dev"
        ManagedBy   = "Terraform"
        Tier        = "database"
  }
}

# Create the second database subnet in Availability Zone B.
resource "aws_subnet" "database_b" {
  # Place this subnet inside our existing VPC.
  vpc_id = aws_vpc.main.id

  # Generate 10.0.22.0/24 from the VPC CIDR.
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 22)

  # Place the subnet in the second Availability Zone.
  availability_zone = "us-east-2b"

  # Do not automatically assign public IPv4 addresses.
  map_public_ip_on_launch = false

  # Identify this subnet as part of the database tier.
  tags = {
    Name        = "aws-infrastructure-platform-database-dev-b"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Tier        = "database"
  }
}


# associate the public A with the public route table
resource "aws_route_table_association" "public_a" {
    # identify the subnet to assiciate
    subnet_id = aws_subnet.public_a.id

    # assign the public route table to this subnet
    route_table_id = aws_route_table.public.id
}