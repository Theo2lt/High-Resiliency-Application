module "network" {
  source = "./module/vpc"
  ### CONTEXT ###
  env     = "dev"
  project = "CloudCarbonFootPrint"

  ### VPC ###
  vpc_cidr_block = "172.32.0.0/16"
  vpc_name       = "CloudCarbonFootPrint"

  ### INTERNET GATEWAY NAME ###
  internet_gateway_name = "gateway"
  nat_gateway_enable    = false

  ### SUBNETS ###
  subnets = {
    public_0 = {
      type  = "public",
      az    = 0,
      scidr = "172.32.2.0/24",
    }
    #public_1 = {
    #  type  = "public",
    #  az    = 1,
    #  scidr = "172.32.3.0/24",
    #}
    #private_0 = {
    #  type  = "private",
    #  az    = 0,
    #  scidr = "172.32.10.0/24",
    #}
    #private_1 = {
    #  type  = "private",
    #  az    = 1,
    #  scidr = "172.32.11.0/24",
    #}
    #private_database_0 = {
    #  type  = "protected",
    #  az    = 0,
    #  scidr = "172.32.20.0/24",
    #}
    #private_database_1 = {
    #  type  = "protected",
    #  az    = 1,
    #  scidr = "172.32.21.0/24",
    #}
  }

  providers = {
    aws = aws.Ireland
  }
}