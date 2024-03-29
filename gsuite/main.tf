variable "dns_zone_id" { type = string }
variable "dns_validation" {
  type    = string
  default = "NO VALIDATION"
}
locals {
  dns_validation = var.dns_validation == "NO VALIDATION" ? [] : ["15 ${var.dns_validation}"]
}
resource "aws_route53_record" "google_domain_MX" {
  zone_id = var.dns_zone_id
  name    = ""
  type    = "MX"
  ttl     = "300"
  records = concat([
    "1  ASPMX.L.GOOGLE.COM.",
    "5	ALT1.ASPMX.L.GOOGLE.COM.",
    "5	ALT2.ASPMX.L.GOOGLE.COM.",
    "10	ALT3.ASPMX.L.GOOGLE.COM.",
    "10	ALT4.ASPMX.L.GOOGLE.COM.",
  ], local.dns_validation)
}
