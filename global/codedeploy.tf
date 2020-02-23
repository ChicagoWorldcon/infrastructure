resource "aws_codedeploy_app" "api" {
  name = var.api_deployment_app_name
}


resource "aws_codedeploy_deployment_group" "dev" {
  deployment_group_name = var.dev_deployment_group
  app_name = aws_codedeploy_app.api.name
  service_role_arn = aws_iam_role.codedeploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key = "Environment"
      type = "KEY_AND_VALUE"
      value = "dev"
    }
  }
  ec2_tag_set {
    ec2_tag_filter {
      key = "Project"
      type = "KEY_AND_VALUE"
      value = var.project
    }
  }
}


resource "aws_codedeploy_deployment_group" "prod" {
  deployment_group_name = var.prod_deployment_group
  app_name = aws_codedeploy_app.api.name
  service_role_arn = aws_iam_role.codedeploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key = "Environment"
      type = "KEY_AND_VALUE"
      value = "prod"
    }
  }
  ec2_tag_set {
    ec2_tag_filter {
      key = "Project"
      type = "KEY_AND_VALUE"
      value = var.project
    }
  }
}
