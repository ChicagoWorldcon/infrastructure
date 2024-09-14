# VPC is in vpc.tf
# site hosts are in registration.tf
# DB is in db.tf

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
  subdomains          = ["2000.chicon.org"]
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
  subdomains          = ["7.chicon.org"]
  acm_certificate_arn = module.global.acm_certificate_arn
  common_tags = merge(
    local.common_tags,
    {
      Application = "Legacy"
      Environment = "prod"
      Division    = "IT"
  })
}

module "chicon-8-site" {
  source      = "./main-site/"
  dns_zone_id = data.aws_route53_zone.chicon.zone_id
  bucket_name = "8.chicon.org"
  aliases     = ["chicon8.org", "chicon8.com"]
  apex_aliases = {
    "chicon.org" : data.aws_route53_zone.chicon.zone_id
  }
  subdomains          = ["8.chicon.org"]
  acm_certificate_arn = module.global.acm_certificate_arn
  use_bucket_acl      = false
  common_tags = merge(
    local.common_tags,
    {
      Application = "Legacy"
      Environment = "prod"
      Division    = "IT"
  })
}

data "aws_region" "current" {}

module "global" {
  source = "./all_stages/"
  providers = {
    aws.acm = aws.us-east-1
  }
  project                   = var.project
  domain_name               = var.domain_name
  subject_alternative_names = ["8.chicon.org", "chicon8.org", "chicon8.com"]
  san_zone_mapping = {
    "chicon8.org" : module.chicon8_org.this_zone_id,
    "chicon8.com" : module.chicon8_com.this_zone_id,
  }
}

module "chicon8_org" {
  source             = "./site-redirect/"
  project            = var.project
  domain_name        = "chicon8.org"
  target_domain_name = module.chicon-8-site.cloudfront_hostname
  target_zone_id     = module.chicon-8-site.cloudfront_hosted_zone_id
}

module "chicon8_com" {
  source             = "./site-redirect/"
  project            = var.project
  domain_name        = "chicon8.com"
  target_domain_name = module.chicon-8-site.cloudfront_hostname
  target_zone_id     = module.chicon-8-site.cloudfront_hosted_zone_id
}

resource "aws_route53_record" "gsuite-txt-chicon8-org" {
  zone_id = module.chicon8_org.this_zone_id
  name    = "chicon8.org"
  type    = "TXT"
  ttl     = "300"
  records = ["google-site-verification=RKhlA_VPVB1SAIqW_mrCcD-Osr-g6kKNXFGRUzfvbBY"]
}
