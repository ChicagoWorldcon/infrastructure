variable "stage" { type = string }
variable "project" { type = string }
variable "application" { type = string }
variable "division" { type = string }

variable "vpc_id" { type = string }
variable "dns_zone_id" { type = string }
variable "security_group_id" { type = string }
variable "public_subnet_id" { type = string }

variable "www_domain_name" { type = string }

variable "instance_type" { type = string }
variable "iam_instance_profile" { type = string }
variable "iam_role_name" { type = string }
variable "volume_size" {
  type    = number
  default = 8
}

variable "log_retention" {
  type    = number
  default = 30
}
