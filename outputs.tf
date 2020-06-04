output "db_endpoint" {
  value = module.db.this_db_instance_endpoint
}

output "db_hostname" {
  value = module.db.this_db_instance_address
}

output "db_instance_id" {
  value = module.db.this_db_instance_id
}

output "reg_hostname" {
  value = {
    dev  = module.registration.dev.public_dns
    prod = module.registration.prod.public_dns
  }
}

output "reg_private_ip" {
  value = {
    dev  = module.registration.dev.private_ip
    prod = module.registration.prod.private_ip
  }
}

output "reg_public_ip" {
  value = {
    dev  = module.registration.dev.public_ip
    prod = module.registration.prod.public_ip
  }
}

output "reg_public_dns" {
  value = {
    dev  = module.registration.dev.public_dns
    prod = module.registration.prod.public_dns
  }
}

output "reg_instance_id" {
  value = {
    dev  = module.registration.dev.instance_id
    prod = module.registration.prod.instance_id
  }
}

output "global_ns" {
  value = module.reg-dns.name_servers
}

output "chicon_ns" {
  value = module.chicon-dns.name_servers
}

output "site" {
  value = {
    dev  = module.registration.dev.www_fqdn
    prod = module.registration.prod.www_fqdn
  }
}

output "api-address" {
  value = {
    prod = module.registration.prod.api_fqdn
  }
}

output "api-port" {
  value = "443"
}

output "www-bucket" {
  value = {
    prod = module.registration.prod.s3_bucket_name
  }
}

output "certificate_arn" {
  value = module.registration.global.certificate_arn
}

output "rds_superuser" {
  value = {
    username         = var.db_superuser_username
    dev_secret_name  = module.dev-creds.db_superuser_password.name
    prod_secret_name = module.prod-creds.db_superuser_password.name
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
