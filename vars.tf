variable "ssh_key_id" {
  type        = string
  description = "Provide this via auto vars"
}

variable "domain_name" {
  default = "chicon.org"
}

variable "secondary_domain_name" {
  default = "chicon.com"
}

variable "region" {
  default = "us-west-2"
}

variable "project" {
  default = "Chicon8"
}

# The RDS superuser
variable "db_superuser_username" {
  default = "chiconadmin"
}

variable "registration_db_name" {
  default = "registration"
}

# These two are historically named "dev" because of some early bad decisions.
# This is not a trivial thing to fix, so I'm not gonna.
variable "registration_staging_db_name" {
  default = "registration_dev"
}

variable "staging_db_site_username" {
  default = "registration_dev_admin"
}

variable "prod_db_site_username" {
  default = "registration_admin"
}

variable "chicon_org_A_records" {
  default = ["192.0.78.150", "192.0.78.229"]
}
