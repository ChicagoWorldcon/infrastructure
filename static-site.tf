module "client" {
  source = "./s3-cloudfront"

  aliases             = ["${local.workspace["reg-www"]}.${var.domain_name}"]
  bucket_name         = "${local.workspace["reg-www"]}.${var.domain_name}"
  acm_certificate_arn = data.terraform_remote_state.global.outputs.certificate_arn
  dns_zone_id         = data.terraform_remote_state.global.outputs.dns_zone_id

  aws_region = var.region

  origin_path             = ""
  cf_distribution_comment = "${local.stage} registration site"
}

module "admin" {
  source = "./s3-cloudfront"

  aliases             = ["${local.workspace["admin-www"]}.${var.domain_name}"]
  bucket_name         = "${local.workspace["admin-www"]}.${var.domain_name}"
  acm_certificate_arn = data.terraform_remote_state.global.outputs.certificate_arn
  dns_zone_id         = data.terraform_remote_state.global.outputs.dns_zone_id

  aws_region = var.region

  origin_path             = ""
  cf_distribution_comment = "${local.stage} admin site"
}



