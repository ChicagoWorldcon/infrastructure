# Input variables
variable "pipeline_name" {
  type    = "string"
  default = "chicago-registration-api"
}

variable "github_username" {
  type    = "string"
  default = "ChicagoWorldcon"
}

variable "github_repo" {
  default = "registration-api"
}

variable "app_name" {
  default = "ChicagoRegistration"
}

variable "deployment_groups" {
  default = {
    dev = "ChicagoRegistration-Dev"
    prod = "ChicagoRegistration-Prod"
  }
}

data "aws_secretsmanager_secret" "github_token" {
  name = "Chicago2022/it/github_token"
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = "${data.aws_secretsmanager_secret.github_token.id}"
}

# CodePipeline resources
resource "aws_s3_bucket" "build_artifact_bucket" {
  bucket = "codepipeline-us-west-2-337692669657"
  acl    = "private"
}

data "aws_iam_policy_document" "codepipeline_assume_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
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

resource "aws_s3_bucket_policy" "build_artifact_bucket" {
  bucket = "${aws_s3_bucket.build_artifact_bucket.bucket}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "SSEAndSSLPolicy",
    "Statement": [
        {
            "Sid": "DenyUnEncryptedObjectUploads",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.build_artifact_bucket.arn}/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption": "aws:kms"
                }
            }
        },
        {
            "Sid": "DenyInsecureConnections",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": "${aws_s3_bucket.build_artifact_bucket.arn}/*",
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "Chicago2022-codepipeline"
  assume_role_policy = "${data.aws_iam_policy_document.codepipeline_assume_policy.json}"
}

resource "aws_iam_role" "codedeploy_role" {
  name               = "Chicago2022-codedeploy"
  assume_role_policy = "${data.aws_iam_policy_document.codedeploy_assume_policy.json}"
}

# Full CodePipeline
resource "aws_codepipeline" "codepipeline" {
  name     = "${var.pipeline_name}"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store = {
    location = "${aws_s3_bucket.build_artifact_bucket.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Repository"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["MyApp"]

      configuration {
        Owner                = "${var.github_username}"
        Repo                 = "${var.github_repo}"
        Branch               = "master"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Staging"

    action {
      name = "ChicagoRegistration-Dev"
      category = "Deploy"
      provider = "CodeDeploy"
      owner = "AWS"
      version = "1"
      input_artifacts = ["MyApp"]

      configuration = {
        ApplicationName = "${var.app_name}"
        DeploymentGroupName = "${var.deployment_groups["dev"]}"
      }
    }
  }

  stage {
    name = "Production"

    action {
      name = "ChicagoRegistration-Prod"
      category = "Deploy"
      provider = "CodeDeploy"
      owner = "AWS"
      version = "1"
      input_artifacts = ["MyApp"]
      
      configuration = {
        ApplicationName = "${var.app_name}"
        DeploymentGroupName = "${var.deployment_groups["prod"]}"
      }
    }
  }
}
