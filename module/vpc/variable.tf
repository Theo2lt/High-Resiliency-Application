### CONTEXT ###

variable "env" {
  type        = string
  description = "type of env (pre-production | production)"
}

variable "project" {
  type        = string
  description = "name of project"
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

variable "nat_gateway_enable" {
  type    = bool
  default = false
}

variable "internet_gateway_name" {
  type = string
}

variable "subnets" {
  type = map(object({
    type  = string
    az    = number
    scidr = string
  }))
}