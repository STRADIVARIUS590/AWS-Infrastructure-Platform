# deploy the networking module 
module "networking" {
  source = "../../modules/networking"

  # pass the VPC CIDR config
  vpc_cidr = var.vpc_cidr

  # pass the NAT gateway deployment toggle
  enable_nat_gateway = var.enable_nat_gateway
}


module "security" {
  source = "../../modules/security"

  # reuse the VPC created in the Networking modulea
  # Es una referencia al output vpc_id del módulo Networking. No estamos escribiendo manualmente el identificador de la VPC.
  vpc_id = module.networking.vpc_id
}