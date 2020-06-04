output "prod" {
  value = {
    security_group_id = module.prod-site.security_group_id
    public_dns        = module.prod-site.public_dns
    private_ip        = module.prod-site.private_ip
    public_ip         = module.prod-site.public_ip
    instance_id       = module.prod-site.id
    s3_bucket_name    = module.prod-client.s3_bucket_name
  }
}

output "dev" {
  value = {
    security_group_id = module.dev-site.security_group_id
    public_dns        = module.dev-site.public_dns
    private_ip        = module.dev-site.private_ip
    public_ip         = module.dev-site.public_ip
    instance_id       = module.dev-site.id
  }
}

output "global" {
  value = {
    certificate_arn = module.global.certificate_arn
  }
}
