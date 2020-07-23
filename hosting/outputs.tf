output "prod" {
  value = {
    security_group_id = module.prod-site.security_group_id
    public_dns        = module.prod-site.public_dns
    private_ip        = module.prod-site.private_ip
    public_ip         = module.prod-site.public_ip
    instance_id       = module.prod-site.id
    www_fqdn          = module.prod-site.site_fqdn

    instance_role_name = module.prod-creds.registration_iam_role_name
  }
}

output "dev" {
  value = {
    security_group_id = module.dev-site.security_group_id
    public_dns        = module.dev-site.public_dns
    private_ip        = module.dev-site.private_ip
    public_ip         = module.dev-site.public_ip
    instance_id       = module.dev-site.id
    www_fqdn          = module.dev-site.site_fqdn

    instance_role_name = module.dev-creds.registration_iam_role_name
  }
}

