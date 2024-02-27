### CONTEXT ###
variable "env" {
  type        = string
  description = "type of env (pre-production | production)"
}

variable "project" {
  type        = string
  description = "name of project"
}

variable "region" {
  type        = string
  description = "default region"
}

### NETWORK ###

variable "vpc_cidr_block" {
  type        = string
  description = "vpc cidr_block "
}

variable "vpc_name" {
  type        = string
  description = "name of vpc"
}

variable "internet_gateway_name" {
  type = string
}

variable "subnets" {
  type = list(any)
}