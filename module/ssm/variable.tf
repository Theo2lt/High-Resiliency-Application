### CONTEXT ###

variable "vpc_id" {
  type        = string
  description = "id of vpc"
}

variable "subnet_ids" {
  type = set(string)
}
