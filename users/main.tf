data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    Project     = var.project
    Environment = "global"
  }
}

data "aws_iam_user" "chrisr" {
  user_name = "chris.rose"
}

data "aws_iam_user" "victoria" {
  user_name = "victoria.garcia"
}

resource "aws_iam_user" "gail" {
  name = "gail.terman"
  path = "/people/program/"
}

resource "aws_iam_user" "henry" {
  name = "henry.balen"
  path = "/people/program/"
}

resource "aws_iam_group" "deployers" {
  name = "deployers"
  path = "/people/it/"
}

resource "aws_iam_group" "wellington" {
  name = "wellington"
  path = "/people/it/"
}

resource "aws_iam_group" "planorama" {
  name = "planorama"
  path = "/people/it/"
}

resource "aws_iam_group_membership" "deployers" {
  name  = "chicon-deployers"
  group = aws_iam_group.deployers.name

  users = [
    data.aws_iam_user.chrisr.user_name,
    data.aws_iam_user.victoria.user_name,
    aws_iam_user.gail.name,
    aws_iam_user.henry.name,
  ]
}

resource "aws_iam_group_membership" "planorama" {
  name  = "chicon-planorama"
  group = aws_iam_group.planorama.name

  users = [
    aws_iam_user.gail.name,
    aws_iam_user.henry.name,
  ]
}

resource "aws_iam_group_membership" "wellington" {
  name  = "chicon-wellington"
  group = aws_iam_group.wellington.name

  users = [
    data.aws_iam_user.victoria.user_name,
  ]
}

resource "aws_iam_group_policy" "planorama-access" {
  name  = "planorama-instance-access-policy"
  group = aws_iam_group.planorama.name

  policy = templatefile("${path.module}/policies/instance-access.json", {
    application = "Planorama"
  })
}

resource "aws_iam_group_policy" "wellington-access" {
  name  = "wellington-instance-access-policy"
  group = aws_iam_group.wellington.name

  policy = templatefile("${path.module}/policies/instance-access.json", {
    application = "Registration"
  })
}
