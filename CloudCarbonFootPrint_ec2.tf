
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20240223.0-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "web_ssm_default" {
  name        = "CloudCarbonFootPrint"
  description = "Managed by terraform"
  vpc_id      = module.network.aws_vpc_vpc.id

  ingress {
    description = ""
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    description = ""
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    description = ""
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_instance" "web" {
  for_each             = module.network.aws_subnet_subnets
  ami                  = "ami-0c1c30571d2dae5c9"
  instance_type        = "t3.medium"
  subnet_id            = each.value.id
  iam_instance_profile = aws_iam_instance_profile.ec2_default_profile.name
  security_groups      = [aws_security_group.web_ssm_default.id]

  associate_public_ip_address = true
  key_name                    = "hra"

  user_data = <<-EOL
  #!/bin/bash
  sudo apt update
  sudo apt upgrade
  sudo apt install -y curl
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt install -y nodejs

  EOL

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = each.key
  }
}
