variable "project" { type = string }
variable "common_tags" {
  default = {}
}

output "deploy_users" {
  value = [
    data.aws_iam_user.chrisr
  ]
}
