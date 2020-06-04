# Input variables
variable "client_pipeline_name" {
  type    = string
  default = "chicago-registration-client"
}

variable "client_github_repo" {
  default = "client"
}

locals {
  client_code = "${var.project}-client-code"
}

resource "aws_s3_bucket" "cache_bucket" {
  bucket = "${lower(var.project)}.codebuild.cache"

  lifecycle_rule {
    enabled = true
    prefix  = "dev-client/"
    expiration {
      days = 1
    }
  }

  lifecycle_rule {
    enabled = true
    prefix  = "dev-admin/"
    expiration {
      days = 1
    }
  }

  lifecycle_rule {
    enabled = true
    prefix  = "prod-client/"
    expiration {
      days = 1
    }
  }

  lifecycle_rule {
    enabled = true
    prefix  = "prod-admin/"
    expiration {
      days = 1
    }
  }

  tags = {
    Project     = var.project
    Environment = "global"
  }
}

module "dev-client" {
  source       = "./codebuild"
  site_title   = "Chicago in 2022 Registration - TESTING"
  name         = "dev-client"
  client_src   = "."
  bucket_name  = local.dev_client_bucket
  api_host     = local.dev_api_host
  project      = var.project
  cache_bucket = aws_s3_bucket.cache_bucket.bucket
  source_url   = "https://github.com/${var.github_username}/${var.client_github_repo}.git"
  role_arn     = aws_iam_role.codebuild_role.arn
}

module "dev-admin" {
  source       = "./codebuild"
  site_title   = "Chicago in 2022 Registration Admin - TESTING"
  name         = "dev-admin"
  client_src   = "members-admin"
  bucket_name  = local.dev_admin_bucket
  api_host     = local.dev_api_host
  project      = var.project
  cache_bucket = aws_s3_bucket.cache_bucket.bucket
  source_url   = "https://github.com/${var.github_username}/${var.client_github_repo}.git"
  role_arn     = aws_iam_role.codebuild_role.arn
}

module "prod-client" {
  source       = "./codebuild"
  site_title   = "Chicago in 2022 Registration"
  name         = "prod-client"
  client_src   = "."
  bucket_name  = local.prod_client_bucket
  api_host     = local.prod_api_host
  project      = var.project
  cache_bucket = aws_s3_bucket.cache_bucket.bucket
  source_url   = "https://github.com/${var.github_username}/${var.client_github_repo}.git"
  role_arn     = aws_iam_role.codebuild_role.arn
}

module "prod-admin" {
  source       = "./codebuild"
  site_title   = "Chicago in 2022 Registration Admin"
  name         = "prod-admin"
  client_src   = "members-admin"
  bucket_name  = local.prod_admin_bucket
  api_host     = local.prod_api_host
  project      = var.project
  cache_bucket = aws_s3_bucket.cache_bucket.bucket
  source_url   = "https://github.com/${var.github_username}/${var.client_github_repo}.git"
  role_arn     = aws_iam_role.codebuild_role.arn
}

# Full CodePipeline
resource "aws_codepipeline" "client-codepipeline" {
  name     = var.client_pipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  depends_on = [
    aws_iam_role_policy_attachment.codebuild_logging_policy,
    aws_iam_role_policy_attachment.codebuild_deploy_policy,
  ]

  artifact_store {
    location = aws_s3_bucket.build_artifact_bucket.bucket
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
      output_artifacts = [local.client_code]

      configuration = {
        Owner                = var.github_username
        Repo                 = var.client_github_repo
        Branch               = "master"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "DeployBeta"

    action {
      name             = "BuildDevClient"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = [local.client_code]
      output_artifacts = []

      configuration = {
        ProjectName = module.dev-client.name
      }
    }

    action {
      name             = "BuildDevAdmin"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = [local.client_code]
      output_artifacts = []

      configuration = {
        ProjectName = module.dev-admin.name
      }
    }

  }

  stage {
    name = "ApproveProd"

    action {
      name     = "ApproveClientToProd"
      category = "Approval"
      provider = "Manual"
      owner    = "AWS"
      version  = "1"

      configuration = {
        NotificationArn    = aws_sns_topic.pipeline_approval.arn
        ExternalEntityLink = "https://${var.region}.console.aws.amazon.com/codepipeline/home?region=${var.region}#/edit/${var.client_pipeline_name}"
      }
    }

  }

  stage {
    name = "DeployProd"

    action {
      name             = "BuildProdClient"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = [local.client_code]
      output_artifacts = []

      configuration = {
        ProjectName = module.prod-client.name
      }
    }

    action {
      name             = "BuildProdAdmin"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = [local.client_code]
      output_artifacts = []

      configuration = {
        ProjectName = module.prod-admin.name
      }
    }
  }

}
