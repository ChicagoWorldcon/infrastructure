# Define our dev API; this is optional

module "dev-site" {
  source = "./nzsite"

  project     = var.project
  stage       = "dev"
  region      = var.region
  dns_zone_id = module.reg-dns.dns_zone_id

  vpc_id            = aws_vpc.chicagovpc.id
  security_group_id = aws_security_group.postgresql.id
  public_subnet_id  = aws_subnet.public.id

  domain_name           = var.domain_name
  db_hostname           = module.db.this_db_instance_address
  db_superuser_username = var.db_superuser_username
  db_site_username      = var.dev_db_site_username
  db_name               = var.dev_db_name
  db_site_secret        = module.dev-creds.db_site_password.name
  db_superuser_secret   = module.prod-creds.db_superuser_password.name
  use_test_certs        = true
  app_name              = "wellington"
  deployment_group_name = module.global.dev_deployment_group

  # secrets
  sendgrid_secret = data.aws_secretsmanager_secret.dev_sendgrid_api_key_secret.name
  jwt_secret      = data.aws_secretsmanager_secret.dev_jwt_secret.name
  session_secret  = data.aws_secretsmanager_secret.dev_session_secret.name
  stripe_secret   = data.aws_secretsmanager_secret.dev_stripe_secret.name
  sidekiq_secret  = data.aws_secretsmanager_secret.dev_sidekiq_secret.name

  # instance distinguishers
  instance_prompt_colour = "34"
  instance_type          = "t2.micro"

  # instance access
  ssh_key_id           = var.ssh_key_id
  iam_instance_profile = module.dev-creds.registration_iam_instance_profile_id
  iam_role_name        = module.dev-creds.registration_iam_role_name

  # remote hosts
  www_domain_name     = "${var.dev_www_prefix}.${var.domain_name}"
  sidekiq_domain_name = "${var.dev_sidekiq_prefix}.${var.domain_name}"
}

module "prod-site" {
  source = "./website"

  project = var.project
  stage   = "prod"
  region  = var.region

  vpc_id            = aws_vpc.chicagovpc.id
  security_group_id = aws_security_group.postgresql.id
  public_subnet_id  = aws_subnet.public.id

  domain_name           = var.domain_name
  db_hostname           = module.db.this_db_instance_address
  db_superuser_username = var.db_superuser_username
  db_site_username      = var.prod_db_site_username
  db_name               = var.db_name
  db_superuser_secret   = module.prod-creds.db_superuser_password.name
  db_site_secret        = module.prod-creds.db_site_password.name
  app_name              = "ChicagoRegistration"
  deployment_group_name = module.global.prod_deployment_group

  # secrets
  sendgrid_api_key = data.aws_secretsmanager_secret.prod_sendgrid_api_key_secret.name
  jwt_secret       = data.aws_secretsmanager_secret.prod_jwt_secret.name
  session_secret   = data.aws_secretsmanager_secret.prod_session_secret.name

  # instance distinguishers
  instance_prompt_colour = "31"
  instance_type          = "t2.medium"

  # instance access
  ssh_key_id           = var.ssh_key_id
  iam_instance_profile = module.prod-creds.registration_iam_instance_profile_id
  iam_role_name        = module.prod-creds.registration_iam_role_name

  # remote hosts
  registration_api_domain_name = "${var.prod_api_prefix}.${var.domain_name}"
  registration_www_domain_name = "${var.prod_www_prefix}.${var.domain_name}"
  admin_www_domain_name        = "${var.prod_admin_prefix}.${var.domain_name}"

}

resource "aws_route53_record" "a_record_org" {
  zone_id = module.reg-dns.dns_zone_id
  name    = "api.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [module.prod-site.public_ip]
}

