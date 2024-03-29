module "dev-secrets" {
  source  = "./secrets/"
  project = var.project
  stage   = "dev"

  common_tags = {
    Division = "IT"
  }
}

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

module "registration-staging-identity" {
  source      = "./identity"
  project     = var.project
  stage       = "staging"
  application = "Registration"

  allow_global_access = true

  route53_zone_id = var.dns_zone_id

  codedeploy_bucket   = "aws-codedeploy-us-west-2"
  codepipeline_bucket = var.codedeploy_bucket

  common_tags = {
    Project     = var.project
    Environment = "staging"
    Division    = "Registration"
  }
}

module "registration-prod-identity" {
  source      = "./identity"
  project     = var.project
  stage       = "prod"
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
  iam_instance_profile = module.registration-staging-identity.iam_instance_profile_id
  iam_role_name        = module.registration-staging-identity.iam_role_name

  # remote hosts
  www_domain_name = "${var.staging_www_prefix}.${var.domain_name}"

  # logging
  log_retention = 7
}

# security groups for the DB
resource "aws_security_group_rule" "db-from-registration-staging" {
  security_group_id        = var.db_security_group_id
  description              = "Staging access to DB via security group"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.staging-site.security_group_id
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
  iam_instance_profile = module.registration-prod-identity.iam_instance_profile_id
  iam_role_name        = module.registration-prod-identity.iam_role_name

  # remote hosts
  www_domain_name = "${var.prod_www_prefix}.${var.domain_name}"

  # logging
  log_retention = 60
}

data "aws_instances" "registration_instances" {
  instance_tags = {
    Application = "Registration"
  }
}

# Chatbot for reg
module "registration-chatbot" {
  source      = "../chatbot/"
  project     = var.project
  application = "Registration"
  instance_ids = sort(distinct(concat([
    module.staging-site.id,
    module.prod-site.id,
  ], data.aws_instances.registration_instances.ids)))
  channels = [
    "#registration-operations"
  ]
}

module "registration-host-alarm" {
  source      = "./host-alarm/"
  project     = var.project
  application = "Registration"
  instance_map = {
    staging = module.staging-site.id
    prod    = module.prod-site.id
  }
  sns_topic_arn = module.registration-chatbot.sns_topic_arn
}

# security groups for the DB
resource "aws_security_group_rule" "db-from-registration-prod" {
  security_group_id        = var.db_security_group_id
  description              = "Staging access to DB via security group"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.prod-site.security_group_id
}

module "guide" {
  source = "./appserver"

  project     = var.project
  stage       = "prod"
  application = "Conclar"
  division    = "Program"

  dns_zone_id = var.dns_zone_id

  vpc_id            = var.vpc_id
  security_group_id = var.security_group_id
  public_subnet_id  = var.vpc_public_subnet_id

  # instance distinguishers
  instance_type = "t2.medium"
  volume_size   = 20

  # instance access
  iam_instance_profile = module.registration-prod-identity.iam_instance_profile_id
  iam_role_name        = module.registration-prod-identity.iam_role_name

  # remote hosts
  www_domain_name = "guide.${var.domain_name}"

  # logging
  log_retention = 60
}

resource "aws_route53_record" "conclar_staging_c" {
  zone_id = var.dns_zone_id
  type    = "CNAME"
  name    = "guide-staging"
  ttl     = 300
  records = [module.guide.site_fqdn]
}

resource "aws_route53_record" "conclar_dev_c" {
  zone_id = var.dns_zone_id
  type    = "CNAME"
  name    = "guide-dev"
  ttl     = 300
  records = [module.guide.site_fqdn]
}
