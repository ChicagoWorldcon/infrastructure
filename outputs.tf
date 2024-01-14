output "global_ns" {
  value = data.aws_route53_zone.chicon.name_servers
}

output "rds_superuser" {
  value = {
    username    = var.db_superuser_username
    secret_name = module.global.db_superuser_password.name
  }
}

output "rds_site_user" {
  value = {
    prod = {
      username    = var.prod_db_site_username
      secret_name = module.prod-creds.db_site_password.name
    }
  }
}

output "ecr_urls" {
  value = module.global.ecr_urls
}

