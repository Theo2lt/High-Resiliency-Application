### ec2endpoint endpoints ###

resource "aws_vpc_endpoint" "ec2_endpoint" {

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2"
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.default_endpoint.id]
  subnet_ids          = var.subnet_ids
  private_dns_enabled = true
}

### ec2messages endpoints ###

resource "aws_vpc_endpoint" "ec2messages_endpoint" {

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.default_endpoint.id]
  subnet_ids         = var.subnet_ids

  private_dns_enabled = true
}


### ssm endpoints ###

resource "aws_vpc_endpoint" "ssm_endpoint" {

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.default_endpoint.id]
  subnet_ids         = var.subnet_ids

  private_dns_enabled = true

}

### ssmmessages endpoint ###

resource "aws_vpc_endpoint" "ssmmessages_endpoint" {

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.default_endpoint.id]
  subnet_ids         = var.subnet_ids

  private_dns_enabled = true
}
