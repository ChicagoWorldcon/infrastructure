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
