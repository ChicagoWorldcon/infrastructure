variable "service" { type = string }
variable "tags" { type = map(any) }
variable "policies" { type = list(string) }

resource "aws_iam_user" "github-user" {
  name = "github-${var.service}"
  path = "/it/github/"
  tags = merge(
    var.tags,
    tomap({ "Client" = "github" })
  )
}

resource "aws_iam_user_policy_attachment" "policy" {
  for_each   = toset(var.policies)
  user       = aws_iam_user.github-user.name
  policy_arn = each.key
}

output "username" { value = aws_iam_user.github-user.name }
