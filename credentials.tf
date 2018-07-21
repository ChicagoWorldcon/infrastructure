module "creds" {
  source = "identity/"
  db_name = "${var.db_name}"
  project = "${var.project}"
  stage   = "${terraform.workspace}"

  db_admin_username = "${var.db_admin_username}"
  db_username       = "${var.db_username}"

  route53_zone_id   = "${data.terraform_remote_state.global.dns_zone_id}"
}
