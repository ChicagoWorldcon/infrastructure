# Input variables
data "aws_secretsmanager_secret" "github_token" {
  name = "Chicago2022/it/github_token"
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}

locals {
  reg_api_code = "${var.project}-registration-api-code"
}

# Full CodePipeline
resource "aws_codepipeline" "codepipeline" {
  name     = var.api_pipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

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
      output_artifacts = [local.reg_api_code]

      configuration = {
        Owner                = var.github_username
        Repo                 = var.api_github_repo
        Branch               = "master"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Production"

    action {
      name            = "ChicagoRegistration-Prod"
      category        = "Deploy"
      provider        = "CodeDeploy"
      owner           = "AWS"
      version         = "1"
      input_artifacts = [local.reg_api_code]

      configuration = {
        ApplicationName     = var.api_deployment_app_name
        DeploymentGroupName = var.prod_deployment_group
      }
    }
  }
}
