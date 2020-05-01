output "db_endpoint" {
  value = aws_db_instance.reg-db.endpoint
}

output "db_hostname" {
  value = aws_db_instance.reg-db.address
}

output "db_instance_id" {
  value = aws_db_instance.reg-db.id
}

output "reg_hostname" {
  value = {
    dev  = module.dev-site.public_dns
    prod = module.prod-site.public_dns
  }
}

output "reg_private_ip" {
  value = {
    dev  = module.dev-site.private_ip
    prod = module.prod-site.private_ip
  }
}

output "reg_public_ip" {
  value = {
    dev  = module.dev-site.public_ip
    prod = module.prod-site.public_ip
  }
}

output "reg_public_dns" {
  value = {
    dev  = module.dev-site.public_dns
    prod = module.prod-site.public_dns
  }
}

output "reg_instance_id" {
  value = {
    dev  = module.dev-site.id
    prod = module.prod-site.id
  }
}

output "global_ns" {
  value = module.global.name_servers
}

output "site" {
  value = {
    dev  = "${var.dev_www_prefix}.${var.domain_name}"
    prod = "${var.prod_www_prefix}.${var.domain_name}"
  }
}

output "api-address" {
  value = {
    prod = "${var.prod_api_prefix}.${var.domain_name}"
  }
}

output "api-port" {
  value = "443"
}

output "www-bucket" {
  value = {
    prod = module.prod-client.s3_bucket_name
  }
}

output "certificate_arn" {
  value = module.global.certificate_arn
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
