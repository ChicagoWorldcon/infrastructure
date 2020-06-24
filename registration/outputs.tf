output "prod" {
  value = {
    # security_group_id = module.prod-site.security_group_id
    # public_dns        = module.prod-site.public_dns
    # private_ip        = module.prod-site.private_ip
    # public_ip         = module.prod-site.public_ip
    # instance_id       = module.prod-site.id
    # www_fqdn          = module.prod-site.site_fqdn
    security_group_id = "UNSET"
    public_dns        = "UNSET"
    private_ip        = "UNSET"
    public_ip         = "UNSET"
    instance_id       = "UNSET"
    www_fqdn          = "UNSET"
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
  }
}

