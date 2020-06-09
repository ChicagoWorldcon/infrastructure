# VPC is in vpc.tf
# site hosts are in registration.tf
# DB is in db.tf

module "registration" {
  source      = "./registration/"
  project     = var.project
  region      = var.region
  dns_zone_id = module.reg-dns.dns_zone_id
  domain_name = var.domain_name

  vpc_id               = aws_vpc.chicagovpc.id
  vpc_public_subnet_id = aws_subnet.public.id

  ssh_key_id = var.ssh_key_id

  db_security_group_id  = aws_security_group.postgresql.id
  db_hostname           = module.db.this_db_instance_address
  db_superuser_username = var.db_superuser_username

  dev_db_site_username  = var.dev_db_site_username
  prod_db_site_username = var.prod_db_site_username

  db_site_secret            = module.dev-creds.db_site_password.name
  db_superuser_secret_name  = module.prod-creds.db_superuser_password.name
  dev_db_site_password_arn  = module.dev-creds.db_site_password.arn
  prod_db_site_password_arn = module.prod-creds.db_site_password.arn

  dev_db_name  = var.dev_db_name
  prod_db_name = var.db_name

}

module "reg-dns" {
  source      = "./dns/"
  domain_name = var.domain_name
  project     = var.project
  role        = "registration"
}

module "chicon-dns" {
  source      = "./dns/"
  domain_name = "chicon.org"
  project     = var.project
  role        = "IT"
}

module "chicon-dns-entries" {
  source                = "./dns-entries/"
  dns_zone_id           = module.chicon-dns.dns_zone_id
  google_dns_validation = "2qv7hpi7tzfqzcwnjq77zd6qyt5uq43ovh4sg42lh4ixnl6c7bua.mx-verification.google.com."
}

module "chicon-legacy-dns-entries" {
  source      = "./legacy-dns/"
  dns_zone_id = module.chicon-dns.dns_zone_id
}

