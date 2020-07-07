output "db_superuser_password" { value = aws_secretsmanager_secret.db_superuser_password }

output "acm_certificate_arn" {
  value = aws_acm_certificate.certificate.arn
}

output "ecr_urls" {
  value = {
    registration = aws_ecr_repository.registration.repository_url
  }
}

output "ecr_pull_policy" {
  value = aws_iam_policy.pull.arn
}

output "ecr_push_policy" {
  value = aws_iam_policy.push.arn
}

