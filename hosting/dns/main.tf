variable "suffix" {
  type    = string
  default = ""
}
variable "dns_zone_id" {}
variable "infra_host" {}

resource "aws_route53_record" "dashboard" {
  zone_id = var.dns_zone_id
  type    = "CNAME"
  name    = "dashboard${var.suffix}"
  ttl     = 300
  records = [var.infra_host]
}

resource "aws_route53_record" "registration" {
  zone_id = var.dns_zone_id
  type    = "CNAME"
  name    = "registration${var.suffix}"
  ttl     = 300
  records = [var.infra_host]
}
