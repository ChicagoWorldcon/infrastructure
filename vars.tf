provider "aws" {
  profile = "chicago"
  region  = "us-west-2"
}

data "terraform_remote_state" "global" {
  backend   = "s3"
  workspace = "default"

  config = {
    bucket = "terraform.offby1.net"
    key    = "chicago/global.tfstate"
    region = "us-west-2"

  }
}

variable "ssh_key_id" {
  type        = string
  description = "Provide this via auto vars"
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

variable "dev_db_name" {
  default = "api-dev"
}

variable "db_password" {
  type = string
}

variable "db_admin_username" { default = "admin" }

