variable "dns_zone_id" {
  type = string
}

variable "sendgrid_records" {
  type = list
}

variable "google_dns_validation" {
  type = string
}

variable "chicon_org_A_records" {
  type = list(string)
}
