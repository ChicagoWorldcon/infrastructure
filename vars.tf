provider "aws" {
  profile = "chicago"
  region = "us-west-2"
}

data "terraform_remote_state" "global" {
  backend = "s3"
  config {
    bucket = "terraform.offby1.net"
    key    = "chicago/global.tfstate"
    region = "us-west-2"
  }
}

variable "domain_name" {
  default = "chicagoworldcon.org"
}

variable "reg-api-fqdn" {}

variable "reg-www-fqdn" {}

variable "region" {
  default = "us-west-2"
}

variable "vpc_cidr_block" {}

variable "public_subnet_cidr" {}

variable "project" {
  default = "Chicago2022"
}

variable "db_username" {
  default = "chicagoadmin"
}

variable "db_name" {
  default = "api"
}

variable "db_superuser_password" {}
variable "db_admin_username" { default = "admin" }
variable "db_admin_password" {}
variable "db_kansa_password" {}
variable "db_hugo_password" {}
variable "db_raami_password" {}

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

