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

module "load_balancer" {
  source = "../../modules/load-balancer"

  # networking dependencies
  vpc_id             = module.networking.vpc_id
  public_subnet_a_id = module.networking.public_subnet_a_id
  public_subnet_b_id = module.networking.public_subnet_b_id

  # security group delendencies
  alb_security_group_id = module.security.alb_security_group_id
}