module "creds" {
  source  = "identity/"
  db_name = "${var.db_name}"
  project = "${var.project}"
  stage   = "${local.stage}"

  db_admin_username = "${var.db_admin_username}"
  db_username       = "${var.db_username}"

  route53_zone_id = "${data.terraform_remote_state.global.dns_zone_id}"

  codedeploy_bucket   = "${local.codedeploy_bucket}"
  codepipeline_bucket = "codepipeline-us-west-2-chicago2022"

  common_tags = "${local.common_tags}"
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

data "aws_secretsmanager_secret" "db_kansa_password_secret" {
  arn = "${module.creds.db_kansa_password_arn}"
}

data "aws_secretsmanager_secret" "db_hugo_password_secret" {
  arn = "${module.creds.db_hugo_password_arn}"
}

data "aws_secretsmanager_secret" "db_raami_password_secret" {
  arn = "${module.creds.db_raami_password_arn}"
}

data "aws_secretsmanager_secret" "stripe_api_key_secret" {
  arn = "${module.creds.stripe_api_key_arn}"
}

data "aws_secretsmanager_secret" "session_secret" {
  arn = "${module.creds.session_secret_arn}"
}

data "aws_secretsmanager_secret" "jwt_secret" {
  arn = "${module.creds.jwt_secret_arn}"
}

data "aws_secretsmanager_secret" "sendgrid_api_key_secret" {
  arn = "${module.creds.sendgrid_api_key_arn}"
}

