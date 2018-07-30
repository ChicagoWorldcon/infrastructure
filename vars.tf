provider "aws" {
  profile = "chicago"
  region = "us-west-2"
}

data "terraform_remote_state" "global" {
  backend = "s3"
  workspace = "default"

  config {
    bucket = "terraform.offby1.net"
    key    = "chicago/global.tfstate"
    region = "us-west-2"
    
  }
}

variable "domain_name" {
  default = "chicagoworldcon.org"
}

variable "secondary_domain_name" {
  default = "chicagoworldcon.com"
}

variable "region" {
  default = "us-west-2"
}

variable "project" {
  default = "Chicago2022"
}

variable "db_username" {
  default = "chicagoadmin"
}

variable "db_name" {
  default = "api"
}

variable "db_admin_username" { default = "admin" }

data "aws_ami" "alinux" {
  most_recent = true

  filter {
    name = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

