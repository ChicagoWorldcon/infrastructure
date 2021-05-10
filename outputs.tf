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
    staging = module.hosting.registration-staging.public_dns
    prod    = module.hosting.registration-prod.public_dns
  }
}

output "reg_private_ip" {
  value = {
    staging = module.hosting.registration-staging.private_ip
    prod    = module.hosting.registration-prod.private_ip
  }
}

output "reg_public_ip" {
  value = {
    staging = module.hosting.registration-staging.public_ip
    prod    = module.hosting.registration-prod.public_ip
  }
}

output "reg_public_dns" {
  value = {
    staging = module.hosting.registration-staging.public_dns
    prod    = module.hosting.registration-prod.public_dns
  }
}

output "reg_instance_id" {
  value = {
    staging = module.hosting.registration-staging.instance_id
    prod    = module.hosting.registration-prod.instance_id
  }
}

output "global_ns" {
  value = data.aws_route53_zone.chicon.name_servers
}

output "site" {
  value = {
    staging = module.hosting.registration-staging.www_fqdn
    prod    = module.hosting.registration-prod.www_fqdn
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

output "cloud-init" {
  value = {
    registration-staging = module.hosting.registration-staging.instance_cloud_init_script
    registration-prod    = module.hosting.registration-prod.instance_cloud_init_script
  }
}
