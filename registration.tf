# Define our dev API; this is optional

module "dev-site" {
  source = "./website"

  project = var.project
  stage   = "dev"
  region  = var.region

  vpc_id            = aws_vpc.chicagovpc.id
  security_group_id = aws_security_group.postgresql.id
  public_subnet_id  = aws_subnet.public.id

  domain_name       = var.domain_name
  db_hostname       = aws_db_instance.reg-db.address
  db_username       = var.db_username
  db_admin_username = var.db_admin_username
  db_name           = var.dev_db_name
  use_test_certs    = true

  # secrets
  db_admin_password = data.aws_secretsmanager_secret_version.db_superuser_password.secret_string
  sendgrid_api_key  = data.aws_secretsmanager_secret.sendgrid_api_key_secret.name
  jwt_secret        = data.aws_secretsmanager_secret.jwt_secret.name
  session_secret    = data.aws_secretsmanager_secret.session_secret.name

  # instance distinguishers
  instance_prompt_colour = "34"
  instance_type          = "t2.micro"

  # instance access
  ssh_key_id           = var.ssh_key_id
  iam_instance_profile = module.dev-creds.registration_iam_instance_profile_id
  iam_role_name        = module.dev-creds.registration_iam_role_name

  # remote hosts
  registration_api_domain_name = "${var.dev_api_prefix}.${var.domain_name}"
  registration_www_domain_name = "${var.dev_www_prefix}.${var.domain_name}"
  admin_www_domain_name        = "${var.dev_admin_prefix}.${var.domain_name}"

}

module "production-site" {
  source = "./website"

  project = var.project
  stage   = "prod"
  region  = var.region

  vpc_id            = aws_vpc.chicagovpc.id
  security_group_id = aws_security_group.postgresql.id
  public_subnet_id  = aws_subnet.public.id

  domain_name       = var.domain_name
  db_hostname       = aws_db_instance.reg-db.address
  db_username       = var.db_username
  db_admin_username = var.db_admin_username
  db_name           = var.db_name

  # secrets
  db_admin_password = data.aws_secretsmanager_secret_version.db_superuser_password.secret_string
  sendgrid_api_key  = data.aws_secretsmanager_secret.sendgrid_api_key_secret.name
  jwt_secret        = data.aws_secretsmanager_secret.jwt_secret.name
  session_secret    = data.aws_secretsmanager_secret.session_secret.name

  # instance distinguishers
  instance_prompt_colour = "31"
  instance_type          = "t2.small"

  # instance access
  ssh_key_id           = var.ssh_key_id
  iam_instance_profile = module.dev-creds.registration_iam_instance_profile_id
  iam_role_name        = module.prod-creds.registration_iam_role_name

  # remote hosts
  registration_api_domain_name = "${var.prod_api_prefix}.${var.domain_name}"
  registration_www_domain_name = "${var.prod_www_prefix}.${var.domain_name}"
  admin_www_domain_name        = "${var.prod_admin_prefix}.${var.domain_name}"

}

resource "aws_route53_record" "a_record_org" {
  zone_id = data.terraform_remote_state.global.outputs.dns_zone_id
  name    = "api.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [module.production-site.public_ip]
}

