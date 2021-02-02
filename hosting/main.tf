module "staging-secrets" {
  source  = "./secrets/"
  project = var.project
  stage   = "staging"

  common_tags = {
    Division = "IT"
  }
}

module "prod-secrets" {
  source  = "./secrets/"
  project = var.project
  stage   = "prod"

  common_tags = {
    Division = "IT"
  }
}

module "staging-creds" {
  source      = "./identity"
  project     = var.project
  stage       = "staging"
  application = "registration"
  db_name     = var.staging_db_name

  route53_zone_id = var.dns_zone_id

  codedeploy_bucket   = "aws-codedeploy-us-west-2"
  codepipeline_bucket = var.codedeploy_bucket

  common_tags = {
    Project     = var.project
    Environment = "staging"
    Division    = "Registration"
  }
}

module "prod-creds" {
  source      = "./identity"
  project     = var.project
  stage       = "prod"
  db_name     = var.prod_db_name
  application = "registration"

  route53_zone_id = var.dns_zone_id

  codedeploy_bucket   = "aws-codedeploy-us-west-2"
  codepipeline_bucket = var.codedeploy_bucket

  common_tags = {
    Project     = var.project
    Environment = "prod"
    Division    = "Registration"
  }
}

module "staging-dns" {
  source      = "./dns"
  suffix      = ".staging"
  dns_zone_id = var.dns_zone_id
  infra_host  = module.staging-site.site_fqdn
}

module "prod-dns" {
  source      = "./dns"
  suffix      = ""
  dns_zone_id = var.dns_zone_id
  infra_host  = module.prod-site.site_fqdn
}

module "staging-site" {
  source = "./appserver"

  project     = var.project
  stage       = "staging"
  application = "Registration"
  division    = "Registration"

  dns_zone_id = var.dns_zone_id

  vpc_id            = var.vpc_id
  security_group_id = var.security_group_id
  public_subnet_id  = var.vpc_public_subnet_id

  # instance distinguishers
  instance_type = "t2.medium"
  volume_size   = 20

  # instance access
  ssh_key_id           = var.ssh_key_id
  iam_instance_profile = module.staging-creds.iam_instance_profile_id
  iam_role_name        = module.staging-creds.iam_role_name

  # remote hosts
  www_domain_name = "${var.staging_www_prefix}.${var.domain_name}"

  # logging
  log_retention = 7
}

module "prod-site" {
  source = "./appserver"

  project     = var.project
  stage       = "prod"
  application = "Registration"
  division    = "Registration"

  dns_zone_id = var.dns_zone_id

  vpc_id            = var.vpc_id
  security_group_id = var.security_group_id
  public_subnet_id  = var.vpc_public_subnet_id

  # instance distinguishers
  instance_type = "t2.medium"
  volume_size   = 20

  # instance access
  ssh_key_id           = var.ssh_key_id
  iam_instance_profile = module.prod-creds.iam_instance_profile_id
  iam_role_name        = module.prod-creds.iam_role_name

  # remote hosts
  www_domain_name = "${var.prod_www_prefix}.${var.domain_name}"

  # logging
  log_retention = 60
}

