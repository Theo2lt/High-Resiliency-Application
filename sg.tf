# Security group elb # 

resource "aws_security_group" "hra_elb" {

  name        = "hra_elb"
  description = "http"
  vpc_id      = aws_vpc.vpc_hra.id
}

resource "aws_security_group_rule" "hra_elb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.hra_elb.id
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "hra_elb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.hra_elb.id
  cidr_blocks       = ["0.0.0.0/0"]
}


# Security group ec2 # 

resource "aws_security_group" "hra_ec2" {

  name        = "hra_ec2"
  description = "http"
  vpc_id      = aws_vpc.vpc_hra.id
}

resource "aws_security_group_rule" "hra_ec2_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.hra_ec2.id
  source_security_group_id = aws_security_group.hra_elb.id
}

resource "aws_security_group_rule" "hra_ec2_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.hra_ec2.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Security group rds # 

resource "aws_security_group" "hra_rds" {

  name        = "hra_rds"
  description = "mysql"
  vpc_id      = aws_vpc.vpc_hra.id
}

resource "aws_security_group_rule" "hra_rds_mysql" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.hra_rds.id
  source_security_group_id = aws_security_group.hra_ec2.id
  #cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "hra_rds_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.hra_rds.id
  cidr_blocks       = ["0.0.0.0/0"]
}