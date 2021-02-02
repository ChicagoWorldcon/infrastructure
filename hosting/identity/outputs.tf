output "iam_instance_profile_id" {
  value = aws_iam_instance_profile.registration.id
}

output "iam_role_name" {
  value = aws_iam_role.registration.name
}
