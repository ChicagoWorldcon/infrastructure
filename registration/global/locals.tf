locals {
  common_tags = {
    Project = "${var.project}"
  }

  prod_client_bucket = "${var.prod_client_bucket_prefix}.${var.domain_name}"
  prod_admin_bucket  = "${var.prod_admin_bucket_prefix}.${var.domain_name}"
  prod_api_host      = "${var.prod_api_host_prefix}.${var.domain_name}:443"
}
