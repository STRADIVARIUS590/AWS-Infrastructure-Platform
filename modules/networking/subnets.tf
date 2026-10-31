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