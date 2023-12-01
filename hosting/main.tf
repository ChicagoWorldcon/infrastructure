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

module "prod-dns" {
  source      = "./dns"
  suffix      = ""
  dns_zone_id = var.dns_zone_id
  infra_host  = module.prod-site.site_fqdn
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
    prod    = module.prod-site.id
  }
  sns_topic_arn = module.registration-chatbot.sns_topic_arn
}

# security groups for the DB
resource "aws_security_group_rule" "db-from-registration-prod" {
  security_group_id        = var.db_security_group_id
  description              = "Production access to DB via security group"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.prod-site.security_group_id
}

