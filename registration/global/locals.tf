locals {
  common_tags = {
    Project = "${var.project}"
  }

  dev_api_host  = "${var.dev_api_host_prefix}.${var.domain_name}:443"
  prod_api_host = "${var.prod_api_host_prefix}.${var.domain_name}:443"
}
