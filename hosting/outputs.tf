output "registration-prod" {
  value = {
    security_group_id = module.prod-site.security_group_id
    public_dns        = module.prod-site.public_dns
    private_ip        = module.prod-site.private_ip
    public_ip         = module.prod-site.public_ip
    instance_id       = module.prod-site.id
    www_fqdn          = module.prod-site.site_fqdn

    instance_role_name         = module.registration-prod-identity.iam_role_name
    instance_cloud_init_script = module.prod-site.cloud_init_script
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

    instance_role_name         = module.registration-staging-identity.iam_role_name
    instance_cloud_init_script = module.staging-site.cloud_init_script
  }
}

output "planorama-dev" {
  value = {
    security_group_id = module.planorama-dev.security_group_id
    public_dns        = module.planorama-dev.public_dns
    private_ip        = module.planorama-dev.private_ip
    public_ip         = module.planorama-dev.public_ip
    instance_id       = module.planorama-dev.id
    www_fqdn          = module.planorama-dev.site_fqdn

    instance_role_name = module.planorama-dev-identity.iam_role_name
  }
}

output "planorama-staging" {
  value = {
    security_group_id = module.planorama-staging.security_group_id
    public_dns        = module.planorama-staging.public_dns
    private_ip        = module.planorama-staging.private_ip
    public_ip         = module.planorama-staging.public_ip
    instance_id       = module.planorama-staging.id
    www_fqdn          = module.planorama-staging.site_fqdn

    instance_role_name = module.planorama-staging-identity.iam_role_name
  }
}

output "planorama-prod" {
  value = {
    security_group_id = module.planorama-prod.security_group_id
    public_dns        = module.planorama-prod.public_dns
    private_ip        = module.planorama-prod.private_ip
    public_ip         = module.planorama-prod.public_ip
    instance_id       = module.planorama-prod.id
    www_fqdn          = module.planorama-prod.site_fqdn

    instance_role_name = module.planorama-prod-identity.iam_role_name
  }
}
