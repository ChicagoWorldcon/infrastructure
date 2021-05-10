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

provider "aws" {
  profile = "chicago"
  region  = "us-east-1"
}

variable "namecheaptoken" {
  description = "namecheap API token"
  type        = string
  sensitive   = true
}

variable "namecheapip" {
  description = "namecheap API IP"
  type        = string
  sensitive   = true
}

variable "namecheapuser" {
  description = "namecheap username"
  type        = string
  sensitive   = true
}

provider "namecheap" {
  username = var.namecheapuser
  api_user = var.namecheapuser
  token    = var.namecheaptoken
  ip       = var.namecheapip
}
