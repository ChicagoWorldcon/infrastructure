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
  db_engine_version       = "12.7"
}

module "hosting" {
  source              = "./hosting/"
  project             = var.project
  region              = var.region
  dns_zone_id         = data.aws_route53_zone.chicon.zone_id
  domain_name         = var.domain_name
  acm_certificate_arn = module.global.acm_certificate_arn

  vpc_id               = module.vpc.vpc_id
  vpc_public_subnet_id = module.vpc.public_subnets[0]

  ssh_key_id = var.ssh_key_id

  security_group_id     = module.vpc.default_security_group_id
  db_security_group_id  = module.chicondb.db_security_group_id
  db_hostname           = module.chicondb.db_instance_address
  db_superuser_username = var.db_superuser_username

  staging_db_site_username = var.staging_db_site_username
  prod_db_site_username    = var.prod_db_site_username

  db_site_secret               = module.staging-creds.db_site_password.name
  db_superuser_secret_name     = module.global.db_superuser_password.name
  staging_db_site_password_arn = module.staging-creds.db_site_password.arn
  prod_db_site_password_arn    = module.prod-creds.db_site_password.arn

  codedeploy_bucket = module.global.artifact_bucket

}

data "aws_route53_zone" "chicon" {
  name = var.domain_name
}

module "chicon-email" {
  source      = "./email/"
  domain_name = var.domain_name
  dns_zone_id = data.aws_route53_zone.chicon.zone_id
}

module "chicon-dns-entries" {
  source                = "./dns-entries/"
  dns_zone_id           = data.aws_route53_zone.chicon.zone_id
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
  chicon_org_A_records = var.chicon_org_A_records
}

module "chicon8-org-dns-entries" {
  source      = "./gsuite/"
  dns_zone_id = module.chicon8_org.this_zone_id
}

module "mailgun" {
  source      = "./mailgun/"
  dns_zone_id = data.aws_route53_zone.chicon.zone_id
  mail_domain = "comms.chicon.org"
}

module "chicon-legacy-dns-entries" {
  source      = "./legacy-dns/"
  dns_zone_id = data.aws_route53_zone.chicon.zone_id
}

module "chicon-2000-site" {
  source              = "./legacy-site/"
  dns_zone_id         = data.aws_route53_zone.chicon.zone_id
  bucket_name         = "2000.chicon.org"
  aliases             = ["2000.chicon.org"]
  acm_certificate_arn = module.global.acm_certificate_arn
  common_tags = merge(
    local.common_tags,
    {
      Application = "Legacy"
      Environment = "prod"
      Division    = "IT"
  })
}

module "chicon-7-site" {
  source              = "./legacy-site/"
  dns_zone_id         = data.aws_route53_zone.chicon.zone_id
  bucket_name         = "7.chicon.org"
  aliases             = ["7.chicon.org"]
  acm_certificate_arn = module.global.acm_certificate_arn
  common_tags = merge(
    local.common_tags,
    {
      Application = "Legacy"
      Environment = "prod"
      Division    = "IT"
  })
}

data "aws_region" "current" {}

module "users" {
  source  = "./users/"
  project = var.project
}

module "global" {
  source = "./all_stages/"
  providers = {
    aws.acm = aws.us-east-1
  }
  project              = var.project
  domain_name          = var.domain_name
  developer_group_name = module.users.deploy_group_name
}

# This is ugly af, but it sorta makes sense?
resource "aws_iam_role_policy_attachment" "instance-pull-planorama-dev" {
  role       = module.hosting.planorama-dev.instance_role_name
  policy_arn = module.global.ecr_pull_policy
}

resource "aws_iam_role_policy_attachment" "instance-pull-planorama-staging" {
  role       = module.hosting.planorama-staging.instance_role_name
  policy_arn = module.global.ecr_pull_policy
}

resource "aws_iam_role_policy_attachment" "instance-pull-planorama-prod" {
  role       = module.hosting.planorama-prod.instance_role_name
  policy_arn = module.global.ecr_pull_policy
}

resource "aws_iam_role_policy_attachment" "instance-pull-staging" {
  role       = module.hosting.registration-staging.instance_role_name
  policy_arn = module.global.ecr_pull_policy
}

resource "aws_iam_role_policy_attachment" "instance-pull-prod" {
  role       = module.hosting.registration-prod.instance_role_name
  policy_arn = module.global.ecr_pull_policy
}

module "prod-creds" {
  source  = "./identity"
  db_name = var.registration_db_name
  project = var.project
  stage   = "prod"

  db_site_username      = var.prod_db_site_username
  db_superuser_username = var.db_superuser_username

  route53_zone_id = data.aws_route53_zone.chicon.zone_id

  common_tags = merge(
    local.common_tags,
    {
      Division    = "IT"
      Environment = "prod"
    }
  )
}

module "prod-planorama-creds" {
  source  = "./identity"
  db_name = var.planorama_prod_db_name
  project = var.project
  stage   = "prod"

  db_site_username      = var.planorama_prod_db_site_username
  db_superuser_username = var.db_superuser_username

  route53_zone_id = data.aws_route53_zone.chicon.zone_id

  common_tags = merge(
    local.common_tags,
    {
      Division    = "Program"
      Environment = "prod"
    }
  )
}

module "staging-creds" {
  source  = "./identity"
  db_name = var.registration_staging_db_name
  project = var.project
  stage   = "staging"

  db_site_username      = var.staging_db_site_username
  db_superuser_username = var.db_superuser_username

  route53_zone_id = data.aws_route53_zone.chicon.zone_id

  common_tags = merge(
    local.common_tags,
    {
      Division    = "IT"
      Environment = "staging"
    }
  )
}

module "staging-planorama-creds" {
  source  = "./identity"
  db_name = var.planorama_staging_db_name
  project = var.project
  stage   = "staging"

  db_site_username      = var.planorama_staging_db_site_username
  db_superuser_username = var.db_superuser_username

  route53_zone_id = data.aws_route53_zone.chicon.zone_id

  common_tags = merge(
    local.common_tags,
    {
      Division    = "Program"
      Environment = "staging"
    }
  )
}

data "aws_secretsmanager_secret" "db_superuser_password_secret" {
  arn = module.global.db_superuser_password.arn
}

data "aws_secretsmanager_secret_version" "db_superuser_password" {
  secret_id = data.aws_secretsmanager_secret.db_superuser_password_secret.id
}

module "bid-domain-redirects" {
  source             = "./site-redirect/"
  project            = var.project
  domain_name        = "chicagoworldconbid.org"
  target_a_records   = var.chicon_org_A_records
  target_domain_name = var.domain_name
}

module "chicon8_org" {
  source             = "./site-redirect/"
  project            = var.project
  domain_name        = "chicon8.org"
  target_a_records   = var.chicon_org_A_records
  target_domain_name = var.domain_name
}

module "chicon8_com" {
  source             = "./site-redirect/"
  project            = var.project
  domain_name        = "chicon8.com"
  target_a_records   = var.chicon_org_A_records
  target_domain_name = var.domain_name
}

module "worldcon80_org" {
  source             = "./site-redirect/"
  project            = var.project
  domain_name        = "worldcon80.org"
  target_a_records   = var.chicon_org_A_records
  target_domain_name = var.domain_name
}

module "bid-site-email" {
  source      = "./email/"
  domain_name = "chicagoworldconbid.org"
  dns_zone_id = module.bid-domain-redirects.this_zone_id
}

module "blog-mx" {
  source = "./gsuite/"

  dns_zone_id    = module.bid-domain-redirects.this_zone_id
  dns_validation = "2qv7hpi7tzfqzcwnjq77zd6qyt5uq43ovh4sg42lh4ixnl6c7bua.mx-verification.google.com."
}

module "dashboard" {
  source  = "./dashboard/"
  project = var.project
}

resource "aws_route53_record" "gsuite-txt" {
  zone_id = module.bid-domain-redirects.this_zone_id
  name    = "chicagoworldconbid.org"
  type    = "TXT"
  ttl     = "300"
  records = ["google-site-verification=MvUZPt3UXJHTY_cMjARPhtxyaJd_4aH5KAWZrywfHRA"]
}

resource "aws_route53_record" "gsuite-txt-chicon8-org" {
  zone_id = module.chicon8_org.this_zone_id
  name    = "chicon8.org"
  type    = "TXT"
  ttl     = "300"
  records = ["google-site-verification=RKhlA_VPVB1SAIqW_mrCcD-Osr-g6kKNXFGRUzfvbBY"]
}
