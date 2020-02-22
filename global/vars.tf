variable "github_username" {
  type    = string
  default = "ChicagoWorldcon"
}

variable "project" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "region" {
  type = string
}

variable "dev_client_bucket_prefix" {
  type = string
}
variable "dev_admin_bucket_prefix" {
  type = string
}
variable "dev_api_host_prefix" {
  type = string
}
variable "prod_client_bucket_prefix" {
  type = string
}
variable "prod_admin_bucket_prefix" {
  type = string
}
variable "prod_api_host_prefix" {
  type = string
}
