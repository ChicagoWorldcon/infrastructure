provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "us-west-2"
}

variable "domain_name" {
  default = "chicagoworldcon.org"
}

variable "reg-api-fqdn" {
  default = "registration-api.chicagoworldcon.org"
}

variable "reg-www-fqdn" {
  default = "registration.chicagoworldcon.org"
}

variable "region" {
  default = "us-west-2"
}

variable "vpc_cidr_block" {
  default = "172.30.0.0/16"
}

variable "public_subnet_cidr" {
  default = "172.30.100.0/24"
}

variable "project" {
  default = "Chicago2022"
}

variable "public_key" {}

variable "db_username" {
  default = "admin"
}

variable "db_name" {
  default = "api"
}

variable "db_password" {}

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

# Enable the bastion for troubleshooting and build
variable "bastion_enabled" {
  default = false
}
