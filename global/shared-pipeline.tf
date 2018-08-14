# CodePipeline resources

resource "aws_s3_bucket" "build_artifact_bucket" {
  bucket = "codepipeline-us-west-2-${lower(var.project)}"
  acl    = "private"
}

data "aws_caller_identity" "account" {}

data "aws_iam_policy" "CodeBuildBasePolicy-client" {
  arn = "arn:aws:iam::${data.aws_caller_identity.account.account_id}:policy/service-role/CodeBuildBasePolicy-${var.project}-client-${var.region}"
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

data "aws_iam_policy_document" "codebuild_assume_policy" {
  statement = {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codebuild_logging_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:us-west-2:${data.aws_caller_identity.account.account_id}:log-group:/aws/codebuild/${module.dev-client.name}",
      "arn:aws:logs:us-west-2:${data.aws_caller_identity.account.account_id}:log-group:/aws/codebuild/${module.dev-client.name}:*",
      "arn:aws:logs:us-west-2:${data.aws_caller_identity.account.account_id}:log-group:/aws/codebuild/${module.dev-admin.name}",
      "arn:aws:logs:us-west-2:${data.aws_caller_identity.account.account_id}:log-group:/aws/codebuild/${module.dev-admin.name}:*",
      "arn:aws:logs:us-west-2:${data.aws_caller_identity.account.account_id}:log-group:/aws/codebuild/${module.prod-client.name}",
      "arn:aws:logs:us-west-2:${data.aws_caller_identity.account.account_id}:log-group:/aws/codebuild/${module.prod-client.name}:*",
      "arn:aws:logs:us-west-2:${data.aws_caller_identity.account.account_id}:log-group:/aws/codebuild/${module.prod-admin.name}",
      "arn:aws:logs:us-west-2:${data.aws_caller_identity.account.account_id}:log-group:/aws/codebuild/${module.prod-admin.name}:*",
    ]
  }
}

data "aws_iam_policy_document" "codebuild_output_policy" {
  statement {
    effect   =  "Allow"
    actions  = [
      "s3:ListAllMyBuckets",
      "s3:HeadBucket"
    ]

    resources = ["*"]
  }

  statement {
    effect   = "Allow"
    actions  = ["s3:*"]

    # This is somewhat hardcoded, regrettably
    resources = [
      "${aws_s3_bucket.build_artifact_bucket.arn}/*",
      "arn:aws:s3:::${local.dev_client_bucket}/*",
      "arn:aws:s3:::${local.prod_client_bucket}/*",
      "arn:aws:s3:::${local.dev_admin_bucket}/*",
      "arn:aws:s3:::${local.prod_admin_bucket}/*",
      "${aws_s3_bucket.cache_bucket.arn}/*",
      "${aws_s3_bucket.build_artifact_bucket.arn}",
      "arn:aws:s3:::${local.dev_client_bucket}",
      "arn:aws:s3:::${local.prod_client_bucket}",
      "arn:aws:s3:::${local.dev_admin_bucket}",
      "arn:aws:s3:::${local.prod_admin_bucket}", 
      "${aws_s3_bucket.cache_bucket.arn}",
   ]
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

resource "aws_iam_role" "codebuild_role" {
  name               = "${var.project}-codebuild"
  assume_role_policy = "${data.aws_iam_policy_document.codebuild_assume_policy.json}"
  path               = "/service-role/"

  
}

resource "aws_iam_role_policy_attachment" "codebuild_logging_policy" {
  role = "${aws_iam_role.codebuild_role.name}"
  policy_arn = "${aws_iam_policy.codebuild_logging_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "codebuild_deploy_policy" {
  role = "${aws_iam_role.codebuild_role.name}"
  policy_arn = "${aws_iam_policy.codebuild_deploy_policy.arn}"
}

resource "aws_iam_policy" "codebuild_logging_policy" {
  name = "CodeBuild-${var.project}-client-${var.region}"
  description = "Policy used in trust relationship with CodeBuild"
  path = "/service-role/"
  policy = "${data.aws_iam_policy_document.codebuild_logging_policy.json}"
}

resource "aws_iam_policy" "codebuild_deploy_policy" {
  name = "CodeBuild-${var.project}-deploy-access-policy-${var.region}"
  # role = "${aws_iam_role.codebuild_role.name}"
  path = "/service-role/"
  policy = "${data.aws_iam_policy_document.codebuild_output_policy.json}"
}

resource "aws_sns_topic" "pipeline_approval" {
  name = "Chicago2022-pipeline-notifications"
  display_name = "C22Pipe"
}
