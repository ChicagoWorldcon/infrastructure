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
  name    = ""
  type    = "A"
  ttl     = 300
  records = var.chicon_org_A_records
}

resource "aws_route53_record" "site_www_cname" {
  zone_id = var.dns_zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = 300
  records = ["chicon.org"]
}

# These are modified at https://admin.google.com/ac/apps/sites/address
resource "aws_route53_record" "staff_wiki_cname" {
  zone_id = var.dns_zone_id
  name    = "wiki"
  type    = "CNAME"
  ttl     = 300
  records = ["ghs.googlehosted.com"]
}

resource "aws_route53_record" "staff_site_cname" {
  zone_id = var.dns_zone_id
  name    = "staff"
  type    = "CNAME"
  ttl     = 300
  records = ["ghs.googlehosted.com"]
}

resource "aws_route53_record" "dh_wiki_cname" {
  zone_id = var.dns_zone_id
  name    = "dh-wiki"
  type    = "CNAME"
  ttl     = 300
  records = ["ghs.googlehosted.com"]
}

resource "aws_route53_record" "dh_site_cname" {
  zone_id = var.dns_zone_id
  name    = "dh"
  type    = "CNAME"
  ttl     = 300
  records = ["ghs.googlehosted.com"]
}
