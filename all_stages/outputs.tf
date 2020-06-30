output "db_superuser_password" { value = aws_secretsmanager_secret.db_superuser_password }

output "acm_certificate_arn" {
  value = aws_acm_certificate.certificate.arn
}

