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
    dev  = module.hosting.dev.public_dns
    prod = module.hosting.prod.public_dns
  }
}

output "reg_private_ip" {
  value = {
    dev  = module.hosting.dev.private_ip
    prod = module.hosting.prod.private_ip
  }
}

output "reg_public_ip" {
  value = {
    dev  = module.hosting.dev.public_ip
    prod = module.hosting.prod.public_ip
  }
}

output "reg_public_dns" {
  value = {
    dev  = module.hosting.dev.public_dns
    prod = module.hosting.prod.public_dns
  }
}

output "reg_instance_id" {
  value = {
    dev  = module.hosting.dev.instance_id
    prod = module.hosting.prod.instance_id
  }
}

output "global_ns" {
  value = module.dns.name_servers
}

output "site" {
  value = {
    dev  = module.hosting.dev.www_fqdn
    prod = module.hosting.prod.www_fqdn
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
    dev = {
      username    = var.dev_db_site_username
      secret_name = module.dev-creds.db_site_password.name
    }
    prod = {
      username    = var.prod_db_site_username
      secret_name = module.prod-creds.db_site_password.name
    }
  }
}
