module "planorama-dev-identity" {
  source      = "./identity"
  project     = var.project
  stage       = "dev"
  db_name     = var.prod_db_name
  application = "planorama"

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

  instance_type = "t2.micro"
  volume_size   = 20

  ssh_key_id           = var.ssh_key_id
  iam_instance_profile = module.planorama-dev-identity.iam_instance_profile_id
  iam_role_name        = module.planorama-dev-identity.iam_role_name

  www_domain_name = "planorama.dev"
  log_retention   = 7
}

