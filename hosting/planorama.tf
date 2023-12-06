module "planorama-dev-identity" {
  source      = "./identity"
  project     = var.project
  stage       = "dev"
  application = "Planorama"

  route53_zone_id = var.dns_zone_id

  codedeploy_bucket   = "aws-codedeploy-us-west-2"
  codepipeline_bucket = var.codedeploy_bucket

  common_tags = {
    Project     = var.project
    Environment = "prod"
    Division    = "Program"
  }
}

module "planorama-dev" {
  source = "./appserver"

  project     = var.project
  stage       = "dev"
  application = "Planorama"
  division    = "Program"

  dns_zone_id = var.dns_zone_id

  vpc_id            = var.vpc_id
  security_group_id = var.security_group_id
  public_subnet_id  = var.vpc_public_subnet_id

  instance_type = "t2.medium"
  volume_size   = 20

  iam_instance_profile = module.planorama-dev-identity.iam_instance_profile_id
  iam_role_name        = module.planorama-dev-identity.iam_role_name

  www_domain_name = "planorama.dev"
  log_retention   = 7
}

resource "aws_security_group_rule" "db-from-planorama-dev" {
  security_group_id        = var.db_security_group_id
  description              = "Planorama dev access to DB via security group"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.planorama-dev.security_group_id
}

module "planorama-staging-identity" {
  source      = "./identity"
  project     = var.project
  stage       = "staging"
  application = "Planorama"

  route53_zone_id = var.dns_zone_id

  codedeploy_bucket   = "aws-codedeploy-us-west-2"
  codepipeline_bucket = var.codedeploy_bucket

  common_tags = {
    Project     = var.project
    Environment = "prod"
    Division    = "Program"
  }
}

module "planorama-staging" {
  source = "./appserver"

  project     = var.project
  stage       = "staging"
  application = "Planorama"
  division    = "Program"

  dns_zone_id = var.dns_zone_id

  vpc_id            = var.vpc_id
  security_group_id = var.security_group_id
  public_subnet_id  = var.vpc_public_subnet_id

  instance_type = "t2.medium"
  volume_size   = 20

  iam_instance_profile = module.planorama-staging-identity.iam_instance_profile_id
  iam_role_name        = module.planorama-staging-identity.iam_role_name

  www_domain_name = "planorama.staging"
  log_retention   = 7
}

resource "aws_security_group_rule" "db-from-planorama-staging" {
  security_group_id        = var.db_security_group_id
  description              = "Planorama staging access to DB via security group"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.planorama-staging.security_group_id
}

module "planorama-prod-identity" {
  source      = "./identity"
  project     = var.project
  stage       = "prod"
  application = "Planorama"

  route53_zone_id = var.dns_zone_id

  codedeploy_bucket   = "aws-codedeploy-us-west-2"
  codepipeline_bucket = var.codedeploy_bucket

  common_tags = {
    Project     = var.project
    Environment = "prod"
    Division    = "Program"
  }
}

module "planorama-prod" {
  source = "./appserver"

  project     = var.project
  stage       = "prod"
  application = "Planorama"
  division    = "Program"

  dns_zone_id = var.dns_zone_id

  vpc_id            = var.vpc_id
  security_group_id = var.security_group_id
  public_subnet_id  = var.vpc_public_subnet_id

  instance_type = "t2.medium"
  volume_size   = 20

  iam_instance_profile = module.planorama-prod-identity.iam_instance_profile_id
  iam_role_name        = module.planorama-prod-identity.iam_role_name

  www_domain_name = "planorama"
  log_retention   = 7
}

resource "aws_security_group_rule" "db-from-planorama-prod" {
  security_group_id        = var.db_security_group_id
  description              = "Planorama prod access to DB via security group"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.planorama-prod.security_group_id
}

data "aws_instances" "planorama_instances" {
  instance_tags = {
    Application = "Planorama"
  }
}

module "planorama-chatbot" {
  source      = "../chatbot"
  project     = var.project
  application = "Planorama"
  instance_ids = sort(distinct(concat([
    module.planorama-prod.id,
    module.planorama-staging.id,
    module.planorama-dev.id,
  ], data.aws_instances.planorama_instances.ids)))
  channels = [
    "#program-software"
  ]
}

module "planorama-host-alarm" {
  source      = "./host-alarm/"
  project     = var.project
  application = "Planorama"
  instance_map = {
    prod    = module.planorama-prod.id
    staging = module.planorama-staging.id
    dev     = module.planorama-dev.id
  }
  sns_topic_arn = module.planorama-chatbot.sns_topic_arn
}
