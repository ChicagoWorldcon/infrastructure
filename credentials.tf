module "creds" {
  source = "identity/"
  db_name = "${var.db_name}"
  project = "${var.project}"

  db_admin_username = "${var.db_admin_username}"
  db_username       = "${var.db_username}"
}
