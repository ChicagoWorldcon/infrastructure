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
}

