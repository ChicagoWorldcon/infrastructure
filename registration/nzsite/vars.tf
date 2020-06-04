variable "stage" { type = string }
variable "project" { type = string }
variable "vpc_id" { type = string }
variable "region" { type = string }

variable "dns_zone_id" { type = string }
variable "security_group_id" { type = string }
variable "public_subnet_id" { type = string }

variable "domain_name" { type = string }
variable "www_domain_name" { type = string }
variable "sidekiq_domain_name" { type = string }

variable "db_superuser_username" { type = string }
variable "db_site_username" { type = string }
variable "db_name" { type = string }
variable "db_superuser_secret" { type = string }
variable "db_site_secret" { type = string }
variable "db_hostname" { type = string }

variable "sendgrid_secret" { type = string }
variable "jwt_secret" { type = string }
variable "session_secret" { type = string }
variable "stripe_secret" { type = string }
variable "sidekiq_secret" { type = string }

variable "instance_type" { type = string }
variable "instance_prompt_colour" { type = string }
variable "iam_instance_profile" { type = string }
variable "iam_role_name" { type = string }
variable "ssh_key_id" { type = string }

variable "use_test_certs" {
  type    = bool
  default = false
}

variable "app_name" { type = string }
variable "deployment_group_name" { type = string }
