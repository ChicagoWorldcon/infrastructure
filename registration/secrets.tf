data "aws_secretsmanager_secret" "prod_session_secret" {
  arn = module.prod-creds.session_secret_arn
}

data "aws_secretsmanager_secret" "prod_jwt_secret" {
  arn = module.prod-creds.jwt_secret_arn
}

data "aws_secretsmanager_secret" "prod_sendgrid_api_key_secret" {
  arn = module.prod-creds.sendgrid_api_key_arn
}

