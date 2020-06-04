variable "dns_zone_id" {
  type = string
}

resource "aws_route53_record" "website_A" {
  zone_id = var.dns_zone_id
  name    = ""
  type    = "A"
  records = [
    "184.168.248.1"
  ]
  ttl = "300"
}

resource "aws_route53_record" "mobile_A" {
  zone_id = var.dns_zone_id
  name    = "mobile"
  type    = "A"
  records = [
    "184.168.248.1"
  ]
  ttl = "300"
}

resource "aws_route53_record" "website_CNAME" {
  zone_id = var.dns_zone_id
  name    = "www"
  type    = "CNAME"
  records = [
    aws_route53_record.website_A.fqdn
  ]
  ttl = "300"
}

resource "aws_route53_record" "chicon7_A" {
  zone_id = var.dns_zone_id
  name    = "chicon7"
  type    = "A"
  records = [
    "184.168.248.1"
  ]
  ttl = "300"
}

resource "aws_route53_record" "twok_A" {
  zone_id = var.dns_zone_id
  name    = "2000"
  type    = "A"
  records = [
    "74.104.188.4"
  ]
  ttl = "300"
}

resource "aws_route53_record" "twok_AAAA" {
  zone_id = var.dns_zone_id
  name    = "2000"
  type    = "AAAA"
  records = [
    "2001:470:1f07:15ff:0:0:0:5000"
  ]
  ttl = "300"
}

