variable "project" { type = string }
variable "common_tags" {
  default = {}
}
variable "domain_name" { type = string }
variable "deploy_users" { type = list(any) }
