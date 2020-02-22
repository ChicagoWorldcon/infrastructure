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
  value = data.terraform_remote_state.global.outputs.name_servers
}

output "site" {
  value = {
    dev  = "${var.dev_www_prefix}.${var.domain_name}"
    prod = "${var.prod_www_prefix}.${var.domain_name}"
  }
}

output "api-address" {
  value = {
    dev  = "${var.dev_api_prefix}.${var.domain_name}"
    prod = "${var.prod_api_prefix}.${var.domain_name}"
  }
}

output "api-port" {
  value = "443"
}

output "www-bucket" {
  value = {
    dev = module.dev-client.s3_bucket_name
    prod = module.prod-client.s3_bucket_name
  }
}

