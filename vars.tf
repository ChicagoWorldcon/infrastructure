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

# The RDS superuser
variable "db_superuser_username" {
  default = "chicagoadmin"
}

variable "db_name" {
  default = "api"
}

variable "dev_db_name" {
  default = "api_dev"
}

variable "db_password" {
  type = string
}

variable "dev_db_site_username" {
  default = "devsite"
}

variable "prod_db_site_username" {
  default = "admin"
}

