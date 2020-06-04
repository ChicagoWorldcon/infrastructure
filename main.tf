# VPC is in vpc.tf
# site hosts are in registration.tf
# DB is in db.tf

module "global" {
  source = "./global/"

  project     = var.project
  domain_name = var.domain_name
  region      = var.region

  dev_client_bucket_prefix = var.dev_www_prefix
  dev_admin_bucket_prefix  = var.dev_admin_prefix
  dev_api_host_prefix      = var.dev_api_prefix
  dev_deployment_group     = "ChicagoRegistration-Dev"

  prod_client_bucket_prefix = var.prod_www_prefix
  prod_admin_bucket_prefix  = var.prod_admin_prefix
  prod_api_host_prefix      = var.prod_api_prefix
  prod_deployment_group     = "ChicagoRegistration-Prod"

  api_deployment_app_name = "ChicagoRegistration"
}

module "reg-dns" {
  source      = "./dns/"
  domain_name = var.domain_name
}

module "chicon-dns" {
  source      = "./dns/"
  domain_name = "chicon.org"
}

module "chicon-dns-entries" {
  source      = "./legacy-dns/"
  dns_zone_id = module.chicon-dns.dns_zone_id
}
