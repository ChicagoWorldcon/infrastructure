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

module "prod-dns" {
  source      = "./dns"
  suffix      = ""
  dns_zone_id = var.dns_zone_id
  infra_host  = module.prod-site.site_fqdn
}


module "dev-dns" {
  source      = "./dns"
  suffix      = ".dev"
  dns_zone_id = var.dns_zone_id
  infra_host  = module.dev-site.site_fqdn
}

module "prod-site" {
  source = "./appserver"

  project     = var.project
  stage       = "prod"
  application = "Registration"

  dns_zone_id = var.dns_zone_id

  vpc_id            = var.vpc_id
  security_group_id = var.security_group_id
  public_subnet_id  = var.vpc_public_subnet_id

  # instance distinguishers
  instance_type = "t2.medium"
  volume_size   = 20

  # instance access
  ssh_key_id           = var.ssh_key_id
  iam_instance_profile = module.prod-creds.registration_iam_instance_profile_id
  iam_role_name        = module.prod-creds.registration_iam_role_name

  # remote hosts
  www_domain_name = "${var.prod_www_prefix}.${var.domain_name}"
}

module "dev-site" {
  source = "./appserver"

  project     = var.project
  stage       = "dev"
  application = "Registration"

  dns_zone_id = var.dns_zone_id

  vpc_id            = var.vpc_id
  security_group_id = var.security_group_id
  public_subnet_id  = var.vpc_public_subnet_id

  # instance distinguishers
  instance_type = "t2.medium"
  volume_size   = 20

  # instance access
  ssh_key_id           = var.ssh_key_id
  iam_instance_profile = module.dev-creds.registration_iam_instance_profile_id
  iam_role_name        = module.dev-creds.registration_iam_role_name

  # remote hosts
  www_domain_name = "${var.dev_www_prefix}.${var.domain_name}"

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


