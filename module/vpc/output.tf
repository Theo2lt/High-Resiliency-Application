output "aws_subnet_subnets" {
  value = aws_subnet.subnets
}

output "aws_vpc_vpc" {
  value = aws_vpc.vpc
}

output "aws_subnet_nat" {
  value = aws_subnet.nat_gateway
}