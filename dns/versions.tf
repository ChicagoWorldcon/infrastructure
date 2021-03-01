terraform {
  required_providers {
    aws = {
      source  = "aws"
      version = ">= 3.10.0"
    }
    namecheap = {
      source  = "terraform.offby1.net/adamdecaf/namecheap"
      version = "~> 1.5.0"
    }
  }
}
