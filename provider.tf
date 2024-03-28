terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.28.0"
    }
  }

  backend "s3" {
    bucket         = "tliotbackend"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "S3Lock"
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "Ireland"
  region = "eu-west-1"
}

