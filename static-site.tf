module "prod-client" {
  source = "./s3-cloudfront"

  aliases             = ["${var.prod_www_prefix}.${var.domain_name}"]
  bucket_name         = "${var.prod_www_prefix}.${var.domain_name}"
  acm_certificate_arn = module.global.certificate_arn
  dns_zone_id         = module.reg-dns.dns_zone_id

  aws_region = var.region

  origin_path             = ""
  cf_distribution_comment = "prod registration site"
}

module "prod-admin" {
  source = "./s3-cloudfront"

  aliases             = ["${var.prod_admin_prefix}.${var.domain_name}"]
  bucket_name         = "${var.prod_admin_prefix}.${var.domain_name}"
  acm_certificate_arn = module.global.certificate_arn
  dns_zone_id         = module.reg-dns.dns_zone_id

  aws_region = var.region

  origin_path             = ""
  cf_distribution_comment = "prod admin site"
}

