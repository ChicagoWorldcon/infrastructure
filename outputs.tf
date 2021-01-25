output "db_endpoint" {
  value = module.chicondb.db_instance_endpoint
}

output "db_hostname" {
  value = module.chicondb.db_instance_address
}

output "db_instance_id" {
  value = module.chicondb.db_instance_id
}

output "reg_hostname" {
  value = {
    staging = module.hosting.staging.public_dns
    prod    = module.hosting.prod.public_dns
  }
}

output "reg_private_ip" {
  value = {
    staging = module.hosting.staging.private_ip
    prod    = module.hosting.prod.private_ip
  }
}

output "reg_public_ip" {
  value = {
    staging = module.hosting.staging.public_ip
    prod    = module.hosting.prod.public_ip
  }
}

output "reg_public_dns" {
  value = {
    staging = module.hosting.staging.public_dns
    prod    = module.hosting.prod.public_dns
  }
}

output "reg_instance_id" {
  value = {
    staging = module.hosting.staging.instance_id
    prod    = module.hosting.prod.instance_id
  }
}

output "global_ns" {
  value = module.dns.name_servers
}

output "site" {
  value = {
    staging = module.hosting.staging.www_fqdn
    prod    = module.hosting.prod.www_fqdn
  }
}

output "rds_superuser" {
  value = {
    username    = var.db_superuser_username
    secret_name = module.global.db_superuser_password.name
  }
}

output "rds_site_user" {
  value = {
    staging = {
      username    = var.staging_db_site_username
      secret_name = module.staging-creds.db_site_password.name
    }
    prod = {
      username    = var.prod_db_site_username
      secret_name = module.prod-creds.db_site_password.name
    }
  }
}

output "ecr_urls" {
  value = module.global.ecr_urls
}
