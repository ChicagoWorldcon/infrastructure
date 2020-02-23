output "dev_deployment_group" {
  value = aws_codedeploy_deployment_group.dev.deployment_group_name
}

output "prod_deployment_group" {
  value = aws_codedeploy_deployment_group.prod.deployment_group_name
}
