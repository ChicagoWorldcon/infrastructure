terraform {
  required_providers {
    aws = {
      source  = "aws"
      version = ">= 3.50.0"
    }
    namecheap = {
      source  = "namecheap/namecheap"
      version = "~> 2.0.0"
    }
    local = {
      source  = "local"
      version = "~> 1.4"
    }
    template = {
      source  = "template"
      version = "~> 2.1"
    }
  }
}

provider "aws" {
  profile = "chicago"
  region  = "us-west-2"
}

provider "aws" {
  profile = "chicago"
  region  = "us-east-1"
  alias   = "us-east-1"
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
  user_name = var.namecheapuser
  api_user  = var.namecheapuser
  api_key   = var.namecheaptoken
  client_ip = var.namecheapip
}
