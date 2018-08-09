locals {
  workspaces = "${merge(local.dev, local.prod)}"
  workspace  = "${local.workspaces[terraform.workspace]}"

  common_tags = {
    Project = "${var.project}"
    Environment = "${terraform.workspace}"
  }

  stage      = "${terraform.workspace}"

  test_cert_flag = "${terraform.workspace == "prod" ? "" : "--test-cert"}"
  # test_cert_flag = "${terraform.workspace == "prod" ? "" : ""}"

  codedeploy_bucket ="aws-codedeploy-us-west-2"

  instance_prompt_colour = "${local.workspace["instance_prompt_colour"]}"
}

