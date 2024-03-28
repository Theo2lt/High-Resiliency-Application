### Security group elb ###

resource "aws_security_group" "application_load_balancer" {
  name        = "sg_alb"
  description = "http"
  vpc_id      = module.network.aws_vpc_vpc.id
}

resource "aws_security_group_rule" "application_load_balancer_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.application_load_balancer.id
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "application_load_balancer_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.application_load_balancer.id
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

### Security group ec2 ###

resource "aws_security_group" "ec2" {
  name        = "sg_ec2"
  description = "http"
  vpc_id      = module.network.aws_vpc_vpc.id
}

resource "aws_security_group_rule" "ec2_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2.id
  source_security_group_id = aws_security_group.application_load_balancer.id
}

resource "aws_security_group_rule" "ec2_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ec2.id
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

### Security group rds ###

resource "aws_security_group" "database" {

  name        = "database"
  description = "mysql"
  vpc_id      = module.network.aws_vpc_vpc.id
}

resource "aws_security_group_rule" "database_mysql" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.database.id
  source_security_group_id = aws_security_group.ec2.id
}
