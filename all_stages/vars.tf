variable "project" { type = string }
variable "common_tags" {
  default = {}
}
variable "domain_name" { type = string }
variable "subject_alternative_names" {
  type    = list(string)
  default = []
}

variable "san_zone_mapping" {
  type    = map(string)
  default = {}
}
