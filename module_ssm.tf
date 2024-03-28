#module "ssm" {
#  source     = "./module/ssm"
#  vpc_id     = module.network.aws_vpc_vpc.id
#  subnet_ids = module.network.aws_subnet_nat[*].id
#}
