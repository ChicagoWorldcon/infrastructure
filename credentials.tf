module "creds" {
  source = "identity/"
  db_name = "${var.db_name}"
  project = "${var.project}"
  stage   = "${terraform.workspace}"

  db_admin_username = "${var.db_admin_username}"
  db_username       = "${var.db_username}"

  route53_zone_id   = "${data.terraform_remote_state.global.dns_zone_id}"
}

data "aws_secretsmanager_secret" "db_superuser_password_secret" {
  arn = "${module.creds.db_superuser_password_arn}"
}

data "aws_secretsmanager_secret_version" "db_superuser_password" {
  secret_id = "${data.aws_secretsmanager_secret.db_superuser_password_secret.id}"
}

data "aws_secretsmanager_secret" "db_admin_password_secret" {
  arn = "${module.creds.db_admin_password_arn}"
}

data "aws_secretsmanager_secret_version" "db_admin_password" {
  secret_id = "${data.aws_secretsmanager_secret.db_admin_password_secret.id}"
}

data "aws_secretsmanager_secret" "db_kansa_password_secret" {
  arn = "${module.creds.db_kansa_password_arn}"
}

data "aws_secretsmanager_secret_version" "db_kansa_password" {
  secret_id = "${data.aws_secretsmanager_secret.db_kansa_password_secret.id}"
}

data "aws_secretsmanager_secret" "db_hugo_password_secret" {
  arn = "${module.creds.db_hugo_password_arn}"
}

data "aws_secretsmanager_secret_version" "db_hugo_password" {
  secret_id = "${data.aws_secretsmanager_secret.db_hugo_password_secret.id}"
}

data "aws_secretsmanager_secret" "db_raami_password_secret" {
  arn = "${module.creds.db_raami_password_arn}"
}

data "aws_secretsmanager_secret_version" "db_raami_password" {
  secret_id = "${data.aws_secretsmanager_secret.db_raami_password_secret.id}"
}

data "aws_secretsmanager_secret" "stripe_api_key_secret" {
  arn = "${module.creds.stripe_api_key_arn}"
}

data "aws_secretsmanager_secret_version" "stripe_api_key" {
  secret_id = "${data.aws_secretsmanager_secret.stripe_api_key_secret.id}"
}
