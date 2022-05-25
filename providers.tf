terraform {
  required_providers {
    aws = {
      source  = "aws"
      version = ">= 3.50.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
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

variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}
