output "prod" {
  value = {
    security_group_id = module.prod-site.security_group_id
    public_dns        = module.prod-site.public_dns
    private_ip        = module.prod-site.private_ip
    public_ip         = module.prod-site.public_ip
    instance_id       = module.prod-site.id
    s3_bucket_name    = module.prod-client.s3_bucket_name
    api_fqdn          = aws_route53_record.a_record_org.fqdn
    www_fqdn          = module.prod-client.s3_bucket_cname
    admin_fqdn        = module.prod-admin.s3_bucket_cname
  }
}

output "global" {
  value = {
    certificate_arn = module.global.certificate_arn
  }
}
