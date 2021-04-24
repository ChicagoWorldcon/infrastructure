locals {
  common_tags = {
    Project     = var.project
    Environment = "global"
    Division    = "IT"
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Create the resources that all stages need.
resource "aws_secretsmanager_secret" "db_superuser_password" {
  name = "${var.project}/db/db_superuser_password"

  tags = merge(
    var.common_tags,
    local.common_tags,
    tomap({
      "Name"        = "DB Superuser",
      "ServiceName" = "ChicagoAdmin"
    })
  )
}

provider "aws" {
  alias = "acm"
}

// Use the AWS Certificate Manager to create an SSL cert for our domain.
resource "aws_acm_certificate" "certificate" {
  provider = aws.acm

  // We want a wildcard cert so we can host subdomains later.
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"

  tags = {
    Project     = var.project
    Name        = var.domain_name
    Environment = "global"
  }

  lifecycle {
    create_before_destroy = true
  }

  // We also want the cert to be valid for the root domain even though we'll be
  // redirecting to the www. domain immediately.
  subject_alternative_names = [var.domain_name]
}

data "aws_route53_zone" "zone" {
  name         = "${var.domain_name}."
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id
  records         = [each.value.record]
  ttl             = 60

}

resource "aws_acm_certificate_validation" "cert" {
  provider        = aws.acm
  certificate_arn = aws_acm_certificate.certificate.arn
  # We're narrow here because we don't actually need a validation for every
  # fqdn, just the main one
  validation_record_fqdns = [aws_route53_record.cert_validation[var.domain_name].fqdn]
}

resource "aws_iam_user" "github-registration" {
  name = "github-registration"
  path = "/it/github/"
  tags = merge(
    var.common_tags,
    local.common_tags,
    tomap({ "Client" = "github" })
  )
}

data "template_file" "policy_push" {
  template = file("${path.module}/policies/ecr-push.json")
}

data "template_file" "policy_pull" {
  template = file("${path.module}/policies/ecr-pull.json")
}

data "template_file" "policy_cleanup" {
  template = file("${path.module}/policies/ecr-cleanup.json")
}

data "template_file" "policy_ecr" {
  template = file("${path.module}/policies/ecr-lifecycle.json")
}

data "template_file" "policy_codedeploy" {
  template = file("${path.module}/policies/codedeploy-deploy.json")

  vars = {
    bucket_name                 = aws_s3_bucket.build_artifact_bucket.bucket
    codedeploy_service_role_arn = aws_iam_role.codedeploy_role.arn
    aws_region                  = data.aws_region.current.name
    account_id                  = data.aws_caller_identity.current.account_id
  }
}

resource "aws_iam_policy" "push" {
  name_prefix = "ecr-push"
  path        = "/it/docker/"

  policy = data.template_file.policy_push.rendered
}

resource "aws_iam_policy" "pull" {
  name_prefix = "ecr-pull"
  path        = "/it/docker/"

  policy = data.template_file.policy_pull.rendered
}

resource "aws_iam_policy" "cleanup" {
  name_prefix = "ecr-cleanup"
  path        = "/it/docker/"

  policy = data.template_file.policy_cleanup.rendered
}

resource "aws_iam_policy" "deploy" {
  name_prefix = "codedeploy"
  path        = "/it/deploy/"

  policy = data.template_file.policy_codedeploy.rendered
}

resource "aws_iam_user_policy_attachment" "github-push" {
  user       = aws_iam_user.github-registration.name
  policy_arn = aws_iam_policy.push.arn
}

resource "aws_iam_user_policy_attachment" "github-pull" {
  user       = aws_iam_user.github-registration.name
  policy_arn = aws_iam_policy.pull.arn
}

resource "aws_iam_user_policy_attachment" "github-cleanup" {
  user       = aws_iam_user.github-registration.name
  policy_arn = aws_iam_policy.cleanup.arn
}

resource "aws_iam_user_policy_attachment" "github-deploy" {
  user       = aws_iam_user.github-registration.name
  policy_arn = aws_iam_policy.deploy.arn
}

# user deployment
resource "aws_iam_group_policy_attachment" "developer-push" {
  group      = var.developer_group_name
  policy_arn = aws_iam_policy.push.arn
}

resource "aws_iam_group_policy_attachment" "developer-pull" {
  group      = var.developer_group_name
  policy_arn = aws_iam_policy.pull.arn
}

resource "aws_iam_group_policy_attachment" "developer-deploy" {
  group      = var.developer_group_name
  policy_arn = aws_iam_policy.deploy.arn
}

resource "aws_ecr_repository" "registration" {
  name                 = "wellington"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    local.common_tags,
    var.common_tags,
    tomap({ "Application" = "web" })
  )
}

resource "aws_ecr_lifecycle_policy" "registration" {
  repository = aws_ecr_repository.registration.name
  policy     = data.template_file.policy_ecr.rendered
}
