terraform {
  required_providers {
    aws = {
      source  = "aws"
      version = ">= 3.10.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
