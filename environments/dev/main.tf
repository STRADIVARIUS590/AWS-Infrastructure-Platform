# deploy the networking module 
module "networking" {
  source = "../../modules/networking"

    vpc_cidr = var.vpc_cidr
}