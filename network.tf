data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_vpc" "vpc_hra" {
  cidr_block = "172.32.0.0/16"
  tags = {
    Name = "hra_vpc"
  }
}

### INTERNET GATEWAY ###

resource "aws_internet_gateway" "gateway_hra" {
  vpc_id = aws_vpc.vpc_hra.id

  tags = {
    Name = "hra_gateway"
  }
}

### SUBNETS ### 

resource "aws_subnet" "private" {
  count                = length(data.aws_availability_zones.available.zone_ids)
  cidr_block           = cidrsubnet(aws_vpc.vpc_hra.cidr_block, 8, count.index) ## 8 because 8 + 16 = 24. binaire decalage
  availability_zone_id = data.aws_availability_zones.available.zone_ids[count.index]
  vpc_id               = aws_vpc.vpc_hra.id
  tags = {
    Name = "hra_${"private"}_${count.index}"
  }
}

resource "aws_subnet" "private_database" {
  count                = length(data.aws_availability_zones.available.zone_ids)
  cidr_block           = cidrsubnet(aws_vpc.vpc_hra.cidr_block, 8, count.index + length(aws_subnet.private)) ## 8 because 8 + 16 = 24. binaire decalage
  availability_zone_id = data.aws_availability_zones.available.zone_ids[count.index]
  vpc_id               = aws_vpc.vpc_hra.id
  tags = {
    Name = "hra_${"private_database"}_${count.index}"
  }
}

resource "aws_subnet" "public" {
  count                = length(data.aws_availability_zones.available.zone_ids)
  cidr_block           = cidrsubnet(aws_vpc.vpc_hra.cidr_block, 8, count.index + length(aws_subnet.private_database) + length(aws_subnet.private)) ## 8 because 8 + 16 = 24. binaire decalage
  availability_zone_id = data.aws_availability_zones.available.zone_ids[count.index]
  vpc_id               = aws_vpc.vpc_hra.id
  tags = {
    Name = "hra_${"public"}_${count.index}"
  }
}

### NAT GATEWAY ###

resource "aws_eip" "ip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.ip.id
  subnet_id     = aws_subnet.public[1].id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gateway_hra]
}

### ROUTE TABLE ###


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_hra.id

  route {
    cidr_block = "0.0.0.0/0"                         # IPV4
    gateway_id = aws_internet_gateway.gateway_hra.id # <- ID internet gateway
  }

  route {
    ipv6_cidr_block = "::/0"                              # IPV6
    gateway_id      = aws_internet_gateway.gateway_hra.id # <- ID internet gateway
  }

  tags = {
    Name = "hra_private_route_table"
  }
}


resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_hra.id

  route {
    cidr_block     = "0.0.0.0/0"                    # IPV4
    nat_gateway_id = aws_nat_gateway.nat_gateway.id # <- ID internet gateway
  }

  tags = {
    Name = "hra_private_route_table"
  }
}


resource "aws_route_table" "private_database_rt" {
  vpc_id = aws_vpc.vpc_hra.id

  tags = {
    Name = "hra_private_database_route_table"
  }
}



### Association route table to subnet 

resource "aws_route_table_association" "route_table_private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}


resource "aws_route_table_association" "route_table_private_database" {
  count          = length(aws_subnet.private_database)
  subnet_id      = aws_subnet.private_database[count.index].id
  route_table_id = aws_route_table.private_database_rt.id
}

resource "aws_route_table_association" "route_table_public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

output "out" {
  value = length(aws_subnet.private)
}


