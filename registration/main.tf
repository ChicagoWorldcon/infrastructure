# Define our dev API; this is optional
# module "global" {
#   source = "./global/"

#   project     = var.project
#   domain_name = var.domain_name
#   region      = var.region

#   dev_api_host_prefix      = var.dev_api_prefix
#   dev_deployment_group     = "ChicagoRegistration-Dev"

#   prod_api_host_prefix      = var.prod_api_prefix
#   prod_deployment_group     = "ChicagoRegistration-Prod"

#   api_deployment_app_name = "ChicagoRegistration"
# }


module "dev-creds" {
  source  = "./identity"
  project = var.project
  stage   = "dev"
  db_name = var.dev_db_name

  route53_zone_id = var.dns_zone_id

  codedeploy_bucket   = "aws-codedeploy-us-west-2"
  codepipeline_bucket = "codepipeline-us-west-2-chicago2022"

  common_tags = {
    Project     = var.project
    Environment = "dev"
  }
}

module "dev-site" {
  source = "./nzsite"

  project     = var.project
  stage       = "dev"
  region      = var.region
  dns_zone_id = var.dns_zone_id

  vpc_id            = var.vpc_id
  security_group_id = var.security_group_id
  public_subnet_id  = var.vpc_public_subnet_id

  domain_name           = var.domain_name
  db_hostname           = var.db_hostname
  db_superuser_username = var.db_superuser_username
  db_site_username      = var.dev_db_site_username
  db_name               = var.dev_db_name
  db_site_secret        = var.db_site_secret
  db_superuser_secret   = var.db_superuser_secret_name
  use_test_certs        = true
  app_name              = "wellington"
  deployment_group_name = var.dev_deployment_group

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

# resource "aws_route53_record" "a_record_org" {
#   zone_id = var.dns_zone_id
#   name    = "${var.prod_api_prefix}.${var.domain_name}"
#   type    = "A"
#   ttl     = 300
#   records = [module.prod-site.public_ip]
# }

