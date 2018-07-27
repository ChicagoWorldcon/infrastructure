module "site" {
  source  = "s3-cloudfront"

  aliases = ["${local.workspace["reg-www"]}.${var.domain_name}"]
  bucket_name = "${local.workspace["reg-www"]}.${var.domain_name}"
  acm_certificate_arn = "${data.terraform_remote_state.global.certificate_arn}"
  dns_zone_id = "${data.terraform_remote_state.global.dns_zone_id}"
  
  aws_region = "${var.region}"

  origin_path = ""
}