data "aws_availability_zones" "available" {
  state = "available"
}

########################
###       VPC        ###
########################

resource "aws_vpc" "vpc" {
  cidr_block             = var.vpc_cidr_block
  default_route_table_id = null
  enable_dns_hostnames   = true
  tags = {
    Name = var.vpc_name
  }
}

########################
### INTERNET GATEWAY ###
########################

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.internet_gateway_name
  }
}

########################
###      SUBNET      ###
########################

resource "aws_subnet" "subnets" {
  for_each             = var.subnets
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = each.value.scidr
  availability_zone_id = data.aws_availability_zones.available.zone_ids[each.value.az]
  tags = {
    Name = "${each.key}"
    Type = "${lookup(var.subnets[each.key], "type")}"
  }
}

########################
###    RT DEFAULT  ###
########################

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  tags = {
    Name = "default"
  }
}

########################
###    ROUTE TABLE   ###
########################

resource "aws_route_table" "table" {
  for_each = aws_subnet.subnets
  vpc_id   = aws_vpc.vpc.id

  tags = {
    Name = "${each.key}"
    Type = "${each.value.tags.Type}"
  }
}

resource "aws_route_table_association" "association" {
  for_each       = toset(keys(aws_subnet.subnets))
  subnet_id      = aws_subnet.subnets["${each.value}"].id
  route_table_id = aws_route_table.table["${each.value}"].id
}

resource "aws_route" "route_internet" {
  for_each               = { for e in aws_route_table.table : e.tags.Name => e.id if e.tags.Type == "public" }
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
  depends_on             = [aws_route_table.table]
}


########################
###   NAT  GATEWAY   ###
########################

resource "aws_subnet" "nat_gateway" {
  count                = var.nat_gateway_enable == true ? 1 : 0
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = "172.32.1.0/24"
  availability_zone_id = data.aws_availability_zones.available.zone_ids[0]
  tags = {
    Name = "_nat_gateway"
  }
}

resource "aws_eip" "nat_gateway" {
  count = var.nat_gateway_enable == true ? 1 : 0
  tags = {
    Name      = "eip_nat"
    subnet_id = aws_subnet.nat_gateway[0].id
  }
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.nat_gateway_enable == true ? 1 : 0
  allocation_id = aws_eip.nat_gateway[0].id
  subnet_id     = aws_subnet.nat_gateway[0].id

  tags = {
    Name = "_nat_gateway"
  }
}

resource "aws_route_table" "nat_gateway" {
  count  = var.nat_gateway_enable == true ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "_nat_gateway"
    Type = "nat_gateway"
  }
}

resource "aws_route_table_association" "nat_gateway" {
  count          = var.nat_gateway_enable == true ? 1 : 0
  subnet_id      = aws_subnet.nat_gateway[0].id
  route_table_id = aws_route_table.nat_gateway[0].id
}

resource "aws_route" "nat_gateway_to_aws_internet_gateway" {
  count                  = var.nat_gateway_enable == true ? 1 : 0
  route_table_id         = aws_route_table.nat_gateway[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

###
resource "aws_route" "private_to_nat_gateway" {
  for_each               = var.nat_gateway_enable == true ? { for e in aws_route_table.table : e.tags.Name => e.id if e.tags.Type == "private" } : {}
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gateway[0].id
}
