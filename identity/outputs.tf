output "registration_iam_instance_profile_id" {
  value = "${aws_iam_instance_profile.registration.id}"
}

output "db_superuser_password_arn" {
  value = "${aws_secretsmanager_secret.db_superuser_password.arn}"
}

output "db_admin_password_arn" {
  value = "${aws_secretsmanager_secret.db_admin_password.arn}"
}

output "db_kansa_password_arn" {
  value = "${aws_secretsmanager_secret.db_kansa_password.arn}"
}

output "db_hugo_password_arn" {
  value = "${aws_secretsmanager_secret.db_hugo_password.arn}"
}

output "db_raami_password_arn" {
  value = "${aws_secretsmanager_secret.db_raami_password.arn}"
}

output "stripe_api_key_arn" {
  value = "${aws_secretsmanager_secret.stripe_api_key.arn}"
}
