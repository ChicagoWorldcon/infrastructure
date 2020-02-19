variable "site_title" {}
variable "name" {}
variable "client_src" {}
variable "bucket_name" {}
variable "project" {}
variable "source_url" {}
variable "role_arn" {}
variable "cache_bucket" {}
variable "api_host" {}

output "name" {
  value = "${aws_codebuild_project.client-build.name}"
}

resource "aws_codebuild_project" "client-build" {
  name          = "${var.project}-${var.name}-build"
  service_role  = "${var.role_arn}"
  badge_enabled = true
  description   = "Build CodeBuild"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = "${var.cache_bucket}/${var.name}"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:6.3.1"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "CLIENT_SRC_DIR"
      value = "${var.client_src}"
    }

    environment_variable {
      name  = "BUCKET_NAME"
      value = "${var.bucket_name}"
    }

    environment_variable {
      name  = "API_HOST"
      value = "${var.api_host}"
    }

    environment_variable {
      name  = "NODE_ENV"
      value = "production"
    }

    environment_variable {
      name  = "TITLE"
      value = "${var.site_title}"
    }

  }

  source {
    type            = "GITHUB"
    location        = "${var.source_url}"
    git_clone_depth = 1
    buildspec       = "buildspec.yml"

    auth {
      type = "OAUTH"
    }
  }

  tags = {
    Project     = "${var.project}"
    Environment = "global"
  }
}

