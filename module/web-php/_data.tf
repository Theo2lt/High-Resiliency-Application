data "aws_subnets" "private" {
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

data "aws_subnets" "protected" {
  filter {
    name   = "tag:Type"
    values = ["protected"]
  }
}

output "name" {
  value = data.aws_subnets.private.ids
}