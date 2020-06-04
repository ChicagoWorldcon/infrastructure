output "db_superuser_password" {
  value = "${aws_secretsmanager_secret.db_superuser_password}"
}

output "db_site_password" {
  value = "${aws_secretsmanager_secret.db_site_password}"
}
