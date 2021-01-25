data "aws_secretsmanager_secret" "prod_session_secret" {
  arn = module.prod-creds.session_secret_arn
}

data "aws_secretsmanager_secret" "prod_jwt_secret" {
  arn = module.prod-creds.jwt_secret_arn
}

data "aws_secretsmanager_secret" "prod_sendgrid_api_key_secret" {
  arn = module.prod-creds.sendgrid_api_key_arn
}

data "aws_secretsmanager_secret" "staging_session_secret" {
  arn = module.staging-creds.session_secret_arn
}

data "aws_secretsmanager_secret" "staging_jwt_secret" {
  arn = module.staging-creds.jwt_secret_arn
}

data "aws_secretsmanager_secret" "staging_sendgrid_api_key_secret" {
  arn = module.staging-creds.sendgrid_api_key_arn
}

data "aws_secretsmanager_secret" "staging_stripe_secret" {
  arn = module.staging-creds.stripe_api_key_arn
}

data "aws_secretsmanager_secret" "staging_sidekiq_secret" {
  arn = module.staging-creds.sidekiq_password_arn
}
