### CONTEXT ###
env     = "production"
project = "hra"
region  = "eu-west-3"

### VPC ###
vpc_cidr_block = "172.32.0.0/16"
vpc_name       = "High-Resiliency-Application"

### INTERNET GATEWAY NAME ###
internet_gateway_name = "gateway"

### SUBNETS ###
subnets = [
  {
    type       = "private",
    az         = 0,
    scidr_size = 8,
    nat        = true
  },
  {
    type       = "private",
    az         = 1,
    scidr_size = 4,
    nat        = true
  },
  {
    type       = "private",
    az         = 2,
    scidr_size = 4,
    nat        = false
  },
  {
    type       = "public",
    az         = 0,
    scidr_size = 8
    nat        = true,
  },
  {
    type       = "public",
    az         = 1,
    scidr_size = 8
    nat        = true
  },
  {
    type       = "public",
    az         = 2,
    scidr_size = 8,
    nat        = false
  },
  {
    type       = "private_database",
    az         = 0,
    scidr_size = 8,
    nat        = false
  },
  {
    type       = "private_database",
    az         = 1,
    scidr_size = 8
    nat        = true
  },
  {
    type       = "private_database",
    az         = 2,
    scidr_size = 8,
    nat        = false
  },
]

