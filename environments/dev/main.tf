# deploy the networking module 
module "networking" {
  source = "../../modules/networking"

  # pass the VPC CIDR config
  vpc_cidr = var.vpc_cidr

  # pass the NAT gateway deployment toggle
  enable_nat_gateway = var.enable_nat_gateway
}