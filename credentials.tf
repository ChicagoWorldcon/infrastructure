module "prod-creds" {
  source  = "./identity"
  db_name = var.db_name
  project = var.project
  stage   = "prod"

  db_site_username      = var.prod_db_site_username
  db_superuser_username = var.db_superuser_username

  route53_zone_id = module.reg-dns.dns_zone_id

  codedeploy_bucket   = "aws-codedeploy-us-west-2"
  codepipeline_bucket = "codepipeline-us-west-2-chicago2022"

  common_tags = merge(
    local.common_tags,
    {
      Environment = "prod"
    }
  )
}

module "dev-creds" {
  source  = "./identity"
  db_name = var.dev_db_name
  project = var.project
  stage   = "dev"

  db_site_username      = var.dev_db_site_username
  db_superuser_username = var.db_superuser_username

  route53_zone_id = module.reg-dns.dns_zone_id

  codedeploy_bucket   = "aws-codedeploy-us-west-2"
  codepipeline_bucket = "codepipeline-us-west-2-chicago2022"

  common_tags = merge(
    local.common_tags,
    {
      Environment = "dev"
    }
  )
}

data "aws_secretsmanager_secret" "db_superuser_password_secret" {
  arn = module.prod-creds.db_superuser_password.arn
}

data "aws_secretsmanager_secret_version" "db_superuser_password" {
  secret_id = data.aws_secretsmanager_secret.db_superuser_password_secret.id
}

data "aws_secretsmanager_secret" "prod_db_site_password_secret" {
  arn = module.prod-creds.db_site_password.arn
}

data "aws_secretsmanager_secret" "prod_session_secret" {
  arn = module.prod-creds.session_secret_arn
}

data "aws_secretsmanager_secret" "prod_jwt_secret" {
  arn = module.prod-creds.jwt_secret_arn
}

data "aws_secretsmanager_secret" "prod_sendgrid_api_key_secret" {
  arn = module.prod-creds.sendgrid_api_key_arn
}

data "aws_secretsmanager_secret" "dev_db_site_password_secret" {
  arn = module.dev-creds.db_site_password.arn
}

data "aws_secretsmanager_secret" "dev_session_secret" {
  arn = module.dev-creds.session_secret_arn
}

data "aws_secretsmanager_secret" "dev_jwt_secret" {
  arn = module.dev-creds.jwt_secret_arn
}

data "aws_secretsmanager_secret" "dev_sendgrid_api_key_secret" {
  arn = module.dev-creds.sendgrid_api_key_arn
}

data "aws_secretsmanager_secret" "dev_stripe_secret" {
  arn = module.dev-creds.stripe_api_key_arn
}

data "aws_secretsmanager_secret" "dev_sidekiq_secret" {
  arn = module.dev-creds.sidekiq_password_arn
}
