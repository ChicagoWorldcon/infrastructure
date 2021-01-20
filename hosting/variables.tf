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

variable "db_hostname" {
  type = string
}

variable "db_superuser_username" {
  type = string
}

variable "db_site_secret" {
  type = string
}

variable "dev_db_site_password_arn" {
  type = string
}

variable "prod_db_site_password_arn" {
  type = string
}

variable "db_superuser_secret_name" {
  type = string
}

variable "dev_db_site_username" {
  type = string
}

variable "prod_db_site_username" {
  type = string
}

variable "dev_db_name" {
  type = string
}

variable "prod_db_name" {
  type = string
}

variable "dev_deployment_group" {
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
