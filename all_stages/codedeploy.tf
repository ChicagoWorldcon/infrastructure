resource "aws_codedeploy_app" "registration" {
  name = "Wellington"
}

resource "aws_codedeploy_app" "planorama" {
  name = "Planorama"
}

resource "aws_s3_bucket" "build_artifact_bucket" {
  bucket = "deploy.${var.domain_name}"
  acl    = "private"

  tags = merge(
    var.common_tags,
    local.common_tags,
  )

}

data "aws_iam_policy_document" "codedeploy_assume_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codedeploy_role" {
  name               = "${var.project}-ops-codedeploy"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_policy.json

  tags = merge(
    var.common_tags,
    local.common_tags,
  )

}

module "registration-group" {
  source       = "./deployment-groups/"
  app_name     = aws_codedeploy_app.registration.name
  service_role = aws_iam_role.codedeploy_role.arn
  app_tag      = "Registration"
  project      = var.project
}

module "planorama-group" {
  source       = "./deployment-groups/"
  app_name     = aws_codedeploy_app.planorama.name
  service_role = aws_iam_role.codedeploy_role.arn
  app_tag      = "Planorama"
  project      = var.project
}
