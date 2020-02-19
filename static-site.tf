module "prod-client" {
  source = "./s3-cloudfront"

  aliases             = ["${var.prod_www_prefix}.${var.domain_name}"]
  bucket_name         = "${var.prod_www_prefix}.${var.domain_name}"
  acm_certificate_arn = data.terraform_remote_state.global.outputs.certificate_arn
  dns_zone_id         = data.terraform_remote_state.global.outputs.dns_zone_id

  aws_region = var.region

  origin_path             = ""
  cf_distribution_comment = "prod registration site"
}

module "prod-admin" {
  source = "./s3-cloudfront"

  aliases             = ["${var.prod_admin_prefix}.${var.domain_name}"]
  bucket_name         = "${var.prod_admin_prefix}.${var.domain_name}"
  acm_certificate_arn = data.terraform_remote_state.global.outputs.certificate_arn
  dns_zone_id         = data.terraform_remote_state.global.outputs.dns_zone_id

  aws_region = var.region

  origin_path             = ""
  cf_distribution_comment = "prod admin site"
}


module "dev-client" {
  source = "./s3-cloudfront"

  aliases             = ["${var.dev_www_prefix}.${var.domain_name}"]
  bucket_name         = "${var.dev_www_prefix}.${var.domain_name}"
  acm_certificate_arn = data.terraform_remote_state.global.outputs.certificate_arn
  dns_zone_id         = data.terraform_remote_state.global.outputs.dns_zone_id

  aws_region = var.region

  origin_path             = ""
  cf_distribution_comment = "dev registration site"
}

module "dev-admin" {
  source = "./s3-cloudfront"

  aliases             = ["${var.dev_admin_prefix}.${var.domain_name}"]
  bucket_name         = "${var.dev_admin_prefix}.${var.domain_name}"
  acm_certificate_arn = data.terraform_remote_state.global.outputs.certificate_arn
  dns_zone_id         = data.terraform_remote_state.global.outputs.dns_zone_id

  aws_region = var.region

  origin_path             = ""
  cf_distribution_comment = "dev admin site"
}


