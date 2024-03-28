
resource "aws_db_instance" "database" {
  db_subnet_group_name   = aws_db_subnet_group.sub_group_database.name
  vpc_security_group_ids = [aws_security_group.database.id]
  allocated_storage      = 5
  db_name                = var.db
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = var.user
  password               = var.pwd
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  storage_encrypted      = true
}

resource "aws_db_subnet_group" "sub_group_database" {
  name       = "main"
  subnet_ids = data.aws_subnets.protected.ids

  tags = {
    Name = "sub_group_database"
  }
}
