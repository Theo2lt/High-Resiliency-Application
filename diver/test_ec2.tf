
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
  name        = "test-endpoint"
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
  ami                  = "ami-0d940f23d527c3ab1"
  instance_type        = "t3.medium"
  subnet_id            = each.value.id
  iam_instance_profile = aws_iam_instance_profile.ec2_default_profile.name
  security_groups      = [aws_security_group.web_ssm_default.id]

  associate_public_ip_address = true
  key_name                    = "hra"

  user_data = <<-EOL
  #!/bin/bash
  
  sudo apt-get update
  sudo apt-get -y install nginx nodejs
  sudo apt install npm
  sudo systemctl restart nginx
  EOL

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = each.key
  }
}
