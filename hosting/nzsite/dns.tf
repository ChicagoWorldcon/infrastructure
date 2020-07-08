resource "aws_route53_record" "a_record_org" {
  zone_id = var.dns_zone_id
  name    = var.www_domain_name
  type    = "A"
  ttl     = 300
  records = [aws_eip.web.public_ip]
}

