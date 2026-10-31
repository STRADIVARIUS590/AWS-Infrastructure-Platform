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
        Name = "aws-infraestructure-platform-public-dev-b"
        Environment = "dev"
        ManagedBy = "Terraform"
        Tier = "public"
    
    }
}


