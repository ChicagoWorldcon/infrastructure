output "registration-prod" {
  value = {
    security_group_id = module.prod-site.security_group_id
    public_dns        = module.prod-site.public_dns
    private_ip        = module.prod-site.private_ip
    public_ip         = module.prod-site.public_ip
    instance_id       = module.prod-site.id
    www_fqdn          = module.prod-site.site_fqdn

    instance_role_name = module.registration-prod-identity.iam_role_name
  }
}

output "registration-staging" {
  value = {
    security_group_id = module.staging-site.security_group_id
    public_dns        = module.staging-site.public_dns
    private_ip        = module.staging-site.private_ip
    public_ip         = module.staging-site.public_ip
    instance_id       = module.staging-site.id
    www_fqdn          = module.staging-site.site_fqdn

    instance_role_name = module.registration-staging-identity.iam_role_name
  }
}

