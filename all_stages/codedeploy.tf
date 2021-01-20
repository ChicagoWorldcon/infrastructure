resource "aws_codedeploy_app" "registration" {
  name = "Wellington"
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

resource "aws_codedeploy_deployment_group" "dev" {
  deployment_group_name  = "dev"
  app_name               = aws_codedeploy_app.registration.name
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = "dev"
    }
  }
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Application"
      type  = "KEY_AND_VALUE"
      value = "Registration"
    }
  }
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Project"
      type  = "KEY_AND_VALUE"
      value = var.project
    }
  }
}


resource "aws_codedeploy_deployment_group" "prod" {
  deployment_group_name  = "prod"
  app_name               = aws_codedeploy_app.registration.name
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = "prod"
    }
  }
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Application"
      type  = "KEY_AND_VALUE"
      value = "Registration"
    }
  }
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Project"
      type  = "KEY_AND_VALUE"
      value = var.project
    }
  }
}
