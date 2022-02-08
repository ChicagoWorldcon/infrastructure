module "plan-z-dev-identity" {
  source      = "./identity"
  project     = var.project
  stage       = "dev"
  application = "PlanZ"

  route53_zone_id = var.dns_zone_id

  codedeploy_bucket   = "aws-codedeploy-us-west-2"
  codepipeline_bucket = var.codedeploy_bucket

  common_tags = {
    Project     = var.project
    Environment = "prod"
    Division    = "Program"
  }
}

module "plan-z-dev" {
  source = "./appserver"

  project     = var.project
  stage       = "dev"
  application = "PlanZ"
  division    = "Program"

  dns_zone_id = var.dns_zone_id

  vpc_id            = var.vpc_id
  security_group_id = var.security_group_id
  public_subnet_id  = var.vpc_public_subnet_id

  instance_type        = "t3.micro"
  volume_size          = 20
  ssh_key_id           = var.ssh_key_id
  iam_instance_profile = module.plan-z-dev-identity.iam_instance_profile_id
  iam_role_name        = module.plan-z-dev-identity.iam_role_name

  www_domain_name = "planz.dev"
  log_retention   = 7
}

resource "aws_security_group_rule" "db-from-plan-z-dev" {
  security_group_id        = var.db_security_group_id
  description              = "Plan Z dev access to DB via security group"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.plan-z-dev.security_group_id
}
