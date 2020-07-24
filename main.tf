# VPC is in vpc.tf
# site hosts are in registration.tf
# DB is in db.tf

module "chicondb" {
  source = "./db/"

  project                 = var.project
  vpc_id                  = module.vpc.vpc_id
  tags                    = local.common_tags
  db_superuser_username   = var.db_superuser_username
  db_superuser_password   = data.aws_secretsmanager_secret_version.db_superuser_password.secret_string
  db_subnet_group_name    = module.vpc.database_subnet_group
  db_engine_major_version = "12"
  db_engine_version       = "12.3"
  security_group_id       = module.vpc.default_security_group_id
}

module "hosting" {
  source      = "./hosting/"
  project     = var.project
  region      = var.region
  dns_zone_id = module.dns.dns_zone_id
  domain_name = var.domain_name

  vpc_id               = module.vpc.vpc_id
  vpc_public_subnet_id = module.vpc.public_subnets[0]

  ssh_key_id = var.ssh_key_id

  security_group_id     = module.vpc.default_security_group_id
  db_hostname           = module.chicondb.db_instance_address
  db_superuser_username = var.db_superuser_username

  dev_db_site_username  = var.dev_db_site_username
  prod_db_site_username = var.prod_db_site_username

  db_site_secret            = module.dev-creds.db_site_password.name
  db_superuser_secret_name  = module.global.db_superuser_password.name
  dev_db_site_password_arn  = module.dev-creds.db_site_password.arn
  prod_db_site_password_arn = module.prod-creds.db_site_password.arn

  dev_db_name  = var.registration_dev_db_name
  prod_db_name = var.registration_db_name

}

module "dns" {
  source      = "./dns/"
  domain_name = var.domain_name
  project     = var.project
  role        = "IT"
}

module "chicon-email" {
  source      = "./email/"
  domain_name = var.domain_name
  dns_zone_id = module.dns.dns_zone_id
}

module "chicon-dns-entries" {
  source                = "./dns-entries/"
  dns_zone_id           = module.dns.dns_zone_id
  google_dns_validation = "2qv7hpi7tzfqzcwnjq77zd6qyt5uq43ovh4sg42lh4ixnl6c7bua.mx-verification.google.com."
  sendgrid_records = [
    # three DKIM tokens
    {
      name  = "em9738.chicon.org"
      value = "u8094855.wl106.sendgrid.net"
    },
    {
      name  = "s1._domainkey.chicon.org"
      value = "s1.domainkey.u8094855.wl106.sendgrid.net"
    },
    {
      name  = "s2._domainkey.chicon.org"
      value = "s2.domainkey.u8094855.wl106.sendgrid.net"
    },
    # two records for link tracking
    {
      name  = "url2986.chicon.org"
      value = "sendgrid.net"
    },
    {
      name  = "8094855.chicon.org"
      value = "sendgrid.net"
    }
  ]
}

module "chicon-legacy-dns-entries" {
  source      = "./legacy-dns/"
  dns_zone_id = module.dns.dns_zone_id
}

module "chicon-2000-site" {
  source              = "./legacy-site/"
  dns_zone_id         = module.dns.dns_zone_id
  bucket_name         = "2000.chicon.org"
  aws_region          = var.region
  aliases             = ["2000.chicon.org"]
  acm_certificate_arn = module.global.acm_certificate_arn
}

module "chicon-7-site" {
  source              = "./legacy-site/"
  dns_zone_id         = module.dns.dns_zone_id
  bucket_name         = "7.chicon.org"
  aws_region          = var.region
  aliases             = ["7.chicon.org"]
  acm_certificate_arn = module.global.acm_certificate_arn
}

data "aws_region" "current" {}

module "global" {
  source = "./all_stages/"
  providers = {
    aws.acm = aws.us-east-1
  }
  project     = var.project
  domain_name = var.domain_name
}

resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/it/users/"
}

resource "aws_iam_group_policy_attachment" "dev-pull" {
  group      = aws_iam_group.developers.name
  policy_arn = module.global.ecr_pull_policy
}

resource "aws_iam_role_policy_attachment" "instance-pull-dev" {
  role       = module.hosting.dev.instance_role_name
  policy_arn = module.global.ecr_pull_policy
}

resource "aws_iam_role_policy_attachment" "instance-pull-prod" {
  role       = module.hosting.prod.instance_role_name
  policy_arn = module.global.ecr_pull_policy
}

module "prod-creds" {
  source  = "./identity"
  db_name = var.registration_db_name
  project = var.project
  stage   = "prod"

  db_site_username      = var.prod_db_site_username
  db_superuser_username = var.db_superuser_username

  route53_zone_id = module.dns.dns_zone_id

  codedeploy_bucket   = "aws-codedeploy-${data.aws_region.current.name}"
  codepipeline_bucket = "codepipeline.${data.aws_region.current.name}.${var.domain_name}"

  common_tags = merge(
    local.common_tags,
    {
      Environment = "prod"
    }
  )
}

module "dev-creds" {
  source  = "./identity"
  db_name = var.registration_dev_db_name
  project = var.project
  stage   = "dev"

  db_site_username      = var.dev_db_site_username
  db_superuser_username = var.db_superuser_username

  route53_zone_id = module.dns.dns_zone_id

  codedeploy_bucket   = "aws-codedeploy-${data.aws_region.current.name}"
  codepipeline_bucket = "codepipeline.${data.aws_region.current.name}.${var.domain_name}"

  common_tags = merge(
    local.common_tags,
    {
      Environment = "dev"
    }
  )
}

data "aws_secretsmanager_secret" "db_superuser_password_secret" {
  arn = module.global.db_superuser_password.arn
}

data "aws_secretsmanager_secret_version" "db_superuser_password" {
  secret_id = data.aws_secretsmanager_secret.db_superuser_password_secret.id
}

