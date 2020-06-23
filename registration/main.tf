module "global" {
  source = "./global/"

  project     = var.project
  domain_name = var.domain_name
  region      = var.region

  prod_client_bucket_prefix = var.prod_www_prefix
  prod_admin_bucket_prefix  = var.prod_admin_prefix
  prod_api_host_prefix      = var.prod_api_prefix
  prod_deployment_group     = "ChicagoRegistration-Prod"

  api_deployment_app_name = "ChicagoRegistration"
}


module "prod-creds" {
  source  = "./identity"
  project = var.project
  stage   = "prod"
  db_name = var.prod_db_name

  route53_zone_id = var.dns_zone_id

  codedeploy_bucket   = "aws-codedeploy-us-west-2"
  codepipeline_bucket = "codepipeline-us-west-2-chicago2022"

  common_tags = {
    Project     = var.project
    Environment = "prod"
  }
}

module "prod-site" {
  source = "./website"

  project = var.project
  stage   = "prod"
  region  = var.region

  vpc_id            = var.vpc_id
  security_group_id = var.db_security_group_id
  public_subnet_id  = var.vpc_public_subnet_id

  domain_name           = var.domain_name
  db_hostname           = var.db_hostname
  db_superuser_username = var.db_superuser_username
  db_site_username      = var.prod_db_site_username
  db_name               = var.prod_db_name
  db_superuser_secret   = var.db_superuser_secret_name
  db_site_secret        = var.db_site_secret
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
  zone_id = var.dns_zone_id
  name    = "${var.prod_api_prefix}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [module.prod-site.public_ip]
}

