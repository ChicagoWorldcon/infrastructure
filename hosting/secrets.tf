data "aws_secretsmanager_secret" "prod_session_secret" {
  arn = module.prod-creds.session_secret_arn
}

data "aws_secretsmanager_secret" "prod_jwt_secret" {
  arn = module.prod-creds.jwt_secret_arn
}

data "aws_secretsmanager_secret" "prod_sendgrid_api_key_secret" {
  arn = module.prod-creds.sendgrid_api_key_arn
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
