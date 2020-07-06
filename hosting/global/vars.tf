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

variable "dev_api_host_prefix" {
  type = string
}
variable "dev_deployment_group" {
  type = string
}

variable "prod_api_host_prefix" {
  type = string
}
variable "prod_deployment_group" {
  type = string
}

variable "api_pipeline_name" {
  type    = string
  default = "chicago-registration-api"
}

variable "api_github_repo" {
  default = "registration-api"
}

variable "api_deployment_app_name" {
  type = string
}


