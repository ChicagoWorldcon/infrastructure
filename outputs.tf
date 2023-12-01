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
    prod    = module.hosting.registration-prod.public_dns
  }
}

output "reg_private_ip" {
  value = {
    prod    = module.hosting.registration-prod.private_ip
  }
}

output "reg_public_ip" {
  value = {
    prod    = module.hosting.registration-prod.public_ip
  }
}

output "reg_public_dns" {
  value = {
    prod    = module.hosting.registration-prod.public_dns
  }
}

output "reg_instance_id" {
  value = {
    prod    = module.hosting.registration-prod.instance_id
  }
}

output "global_ns" {
  value = data.aws_route53_zone.chicon.name_servers
}

output "site" {
  value = {
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
    prod = {
      username    = var.prod_db_site_username
      secret_name = module.prod-creds.db_site_password.name
    }
  }
}

output "planorama_site_user" {
  value = {
    staging = {
      username    = var.planorama_staging_db_site_username
      secret_name = module.staging-planorama-creds.db_site_password.name
    }
    prod = {
      username    = var.planorama_prod_db_site_username
      secret_name = module.prod-planorama-creds.db_site_password.name
    }
  }
}

output "hugo_packet_secrets" {
  value = module.hugo-packet.api_secrets
}

output "ecr_urls" {
  value = module.global.ecr_urls
}

output "cloud-init" {
  value = {
    registration-prod    = module.hosting.registration-prod.instance_cloud_init_script
  }
}
