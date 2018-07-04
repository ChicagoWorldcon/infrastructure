provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "us-west-2"
}

variable "domain_name" {
  default = "chicagoworldcon.org"
}

variable "region" {
  default = "us-west-2"
}

variable "project" {
  default = "Chicago2022"
}

data "aws_ami" "alinux" {
  most_recent = true

  filter {
    name = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

