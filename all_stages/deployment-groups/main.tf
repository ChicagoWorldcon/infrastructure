variable "app_name" { type = string }
variable "service_role" { type = string }
variable "project" { type = string }
variable "app_tag" { type = string }

resource "aws_codedeploy_deployment_group" "dev" {
  deployment_group_name  = "dev"
  app_name               = var.app_name
  service_role_arn       = var.service_role
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
      value = var.app_tag
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


resource "aws_codedeploy_deployment_group" "staging" {
  deployment_group_name  = "staging"
  app_name               = var.app_name
  service_role_arn       = var.service_role
  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = "staging"
    }
  }
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Application"
      type  = "KEY_AND_VALUE"
      value = var.app_tag
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
  app_name               = var.app_name
  service_role_arn       = var.service_role
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
      value = var.app_tag
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
