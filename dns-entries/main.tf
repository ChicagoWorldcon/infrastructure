module "google_domain_MX" {
  source = "../gsuite/"

  dns_zone_id    = var.dns_zone_id
  dns_validation = var.google_dns_validation
}

resource "aws_route53_record" "sendgrid-dkim" {
  count   = length(var.sendgrid_records)
  zone_id = var.dns_zone_id
  name    = lookup(element(var.sendgrid_records, count.index), "name")
  type    = "CNAME"
  ttl     = 600
  records = [lookup(element(var.sendgrid_records, count.index), "value")]
}

resource "aws_route53_record" "site_a_records" {
  zone_id = var.dns_zone_id
  name    = "staging.chicon.org"
  type    = "A"
  ttl     = 300
  records = var.chicon_org_A_records
}
