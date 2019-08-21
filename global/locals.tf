locals {
  stages             = "${merge(local.dev, local.prod)}"
  dev_client_bucket  = "${lookup(local.stages["dev"], "reg-www")}.${var.domain_name}"
  dev_admin_bucket   = "${lookup(local.stages["dev"], "admin-www")}.${var.domain_name}"
  dev_api_host       = "${lookup(local.stages["dev"], "reg-api")}.${var.domain_name}:443"
  prod_client_bucket = "${lookup(local.stages["prod"], "reg-www")}.${var.domain_name}"
  prod_admin_bucket  = "${lookup(local.stages["prod"], "admin-www")}.${var.domain_name}"
  prod_api_host      = "${lookup(local.stages["prod"], "reg-api")}.${var.domain_name}:443"
}
