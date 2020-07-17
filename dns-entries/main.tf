module "google_domain_MX" {
  source = "../gsuite/"

  dns_zone_id    = var.dns_zone_id
  dns_validation = var.google_dns_validation
}
