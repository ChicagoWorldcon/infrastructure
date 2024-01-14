variable "project" {
  type        = string
  description = "The top level project for taggigng"
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "dns_zone_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "ssh_key_id" {
  type = string
}

variable "vpc_public_subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "staging_deployment_group" {
  type    = string
  default = "ChicagoRegistration-Dev"
}

variable "prod_deployment_group" {
  type    = string
  default = "ChicagoRegistration-Prod"
}

variable "codedeploy_bucket" {
  type = string
}
