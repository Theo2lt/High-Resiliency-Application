data "aws_availability_zones" "available" {
  state = "available"
}

### VPC ###
resource "aws_vpc" "vpc" {
  cidr_block             = var.vpc_cidr_block
  default_route_table_id = null
  tags = {
    Name = var.vpc_name
  }
}

### INTERNET GATEWAY ###
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.internet_gateway_name
  }
}

### SUBNETS ###
resource "aws_subnet" "subnet" {
  for_each             = { for i in range(length(var.subnets)) : i => var.subnets[i] }
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = cidrsubnet(aws_vpc.vpc.cidr_block, 8, sum([for i in range(each.key + 1) : lookup(var.subnets[i], "scidr_size")]))
  availability_zone_id = data.aws_availability_zones.available.zone_ids[each.value.az]
  tags = {
    Name = "${lookup(var.subnets[each.key], "type")}_az_${each.value.az}"
    Type = "${lookup(var.subnets[each.key], "type")}"
    Nat = lookup(var.subnets[each.key], "nat")
  }
}

### ROUTE TABLE ###

resource "aws_route_table" "table" {
  for_each = toset([for e in var.subnets : "${e.type}"])
  vpc_id   = aws_vpc.vpc.id

  tags = {
    Name = "${each.key}"
  }
}

resource "aws_route_table_association" "association" {
  for_each       = aws_subnet.subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.table["${each.value.tags.Type}"].id
}

resource "aws_route" "route" {
  route_table_id         = aws_route_table.table["public"].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}


#resource "aws_nat_gateway" "nat_gateway" {
#  allocation_id = aws_eip.ip.id
#  subnet_id     = aws_subnet.subnet[0].id
#
#  tags = {
#    Name = "gw NAT"
#  }
#
#  # To ensure proper ordering, it is recommended to add an explicit dependency
#  # on the Internet Gateway for the VPC.
#  #depends_on = [aws_internet_gateway.gateway_hra]
#} 





### NAT GATEWAY ###

resource "aws_eip" "ip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each = toset([for e in aws_subnet.subnet : e.id if e.tags.Nat == "true"])
  allocation_id = aws_eip.ip.id
  subnet_id     = each.value

  tags = {
    Name = "NAT_${each.value}"
  }
}



#resource "aws_route_table" "public_rt" {
#  vpc_id = aws_vpc.vpc.id
#
#  route {
#    cidr_block = "0.0.0.0/0"                         # IPV4
#    gateway_id = aws_internet_gateway.gateway.id # <- ID internet gateway
#  }
#
#  route {
#    ipv6_cidr_block = "::/0"                              # IPV6
#    gateway_id      = aws_internet_gateway.gateway.id # <- ID internet gateway
#  }
#
#  tags = {
#    Name = "hra_private_route_table"
#  }
#}


#resource "aws_route_table" "private_rt" {
#  vpc_id = aws_vpc.vpc.id
#
#  route {
#    cidr_block     = "0.0.0.0/0"                    # IPV4
#    nat_gateway_id = aws_nat_gateway.nat_gateway.id # <- ID internet gateway
#  }
#
#  tags = {
#    Name = "hra_private_route_table"
#  }
#}


#resource "aws_route_table" "private_database_rt" {
#  vpc_id = aws_vpc.vpc.id
#
#  tags = {
#    Name = "hra_private_database_route_table"
#  }
#}
