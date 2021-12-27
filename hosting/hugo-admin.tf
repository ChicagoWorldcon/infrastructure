resource "aws_route53_record" "hugo-admin-prod" {
  zone_id = var.dns_zone_id
  type    = "CNAME"
  name    = "hugo-admin.prod"
  ttl     = 300
  records = [module.staging-site.site_fqdn]
}

resource "aws_route53_record" "hugo-admin-staging" {
  zone_id = var.dns_zone_id
  type    = "CNAME"
  name    = "hugo-admin.staging"
  ttl     = 300
  records = [module.staging-site.site_fqdn]
}
