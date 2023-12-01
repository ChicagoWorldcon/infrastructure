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

resource "aws_iam_user" "mike" {
  name = "mike.tatroe"
  path = "/people/program/"
}

resource "aws_iam_user" "henry" {
  name = "henry.balen"
  path = "/people/program/"
}

resource "aws_iam_user" "leane" {
  name = "leane.verhulst"
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

resource "aws_iam_group" "dba" {
  name = "dba"
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
    aws_iam_user.mike.name,
    aws_iam_user.leane.name,
  ]
}

resource "aws_iam_group_membership" "wellington" {
  name  = "chicon-wellington"
  group = aws_iam_group.wellington.name

  users = [
    data.aws_iam_user.victoria.user_name,
  ]
}

resource "aws_iam_group_membership" "dba" {
  name  = "chicon-dba"
  group = aws_iam_group.dba.name

  users = [
    data.aws_iam_user.chrisr.user_name,
    aws_iam_user.henry.name,
  ]
}

resource "aws_iam_group_policy" "wellington-access" {
  name  = "wellington-instance-access-policy"
  group = aws_iam_group.wellington.name

  policy = templatefile("${path.module}/policies/instance-access.json", {
    application = "Registration"
  })
}

data "aws_iam_policy" "amazon_rds_performance_insights_ro" {
  name = "AmazonRDSPerformanceInsightsReadOnly"
}

resource "aws_iam_group_policy_attachment" "dba-performance-insights" {
  group      = aws_iam_group.dba.name
  policy_arn = data.aws_iam_policy.amazon_rds_performance_insights_ro.arn
}
