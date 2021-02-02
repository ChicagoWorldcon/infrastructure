variable "project" { type = string }
variable "common_tags" {
  default = {}
}

output "deploy_group_arn" {
  value = aws_iam_group.deployers.arn
}

output "deploy_group_name" {
  value = aws_iam_group.deployers.name
}

