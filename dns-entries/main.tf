module "google_domain_MX" {
  source = "../gsuite/"

  dns_zone_id    = var.dns_zone_id
  dns_validation = var.google_dns_validation
}

variable "sendgrid_records" {
  type = list
}

resource "aws_route53_record" "sendgrid-dkim" {
  count   = length(var.sendgrid_records)
  zone_id = var.dns_zone_id
  name    = lookup(element(var.sendgrid_records, count.index), "name")
  type    = "CNAME"
  ttl     = 600
  records = [lookup(element(var.sendgrid_records, count.index), "value")]
}

