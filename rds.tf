resource "aws_db_instance" "db_hra" {
  db_subnet_group_name   = aws_db_subnet_group.sub_group_hra_db.name
  vpc_security_group_ids = [aws_security_group.hra_rds.id]
  allocated_storage      = 5
  db_name                = var.db
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = var.user
  password               = var.pwd
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
}

resource "aws_db_subnet_group" "sub_group_hra_db" {
  name       = "main"
  subnet_ids = aws_subnet.private_database.*.id

  tags = {
    Name = "hra_subnet_group"
  }
}
