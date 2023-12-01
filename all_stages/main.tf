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

module "registration" {
  source  = "./github/"
  service = "registration"
  tags    = merge(var.common_tags, local.common_tags)
  policies = [
    aws_iam_policy.push.arn,
    aws_iam_policy.pull.arn,
    aws_iam_policy.cleanup.arn,
    aws_iam_policy.deploy.arn,
  ]
}



module "planorama" {
  source  = "./github/"
  service = "planorama"
  tags    = merge(var.common_tags, local.common_tags)
  policies = [
    aws_iam_policy.push.arn,
    aws_iam_policy.pull.arn,
    aws_iam_policy.cleanup.arn,
    aws_iam_policy.deploy.arn,
  ]
}

resource "aws_iam_policy" "push" {
  name_prefix = "ecr-push"
  path        = "/it/docker/"

  policy = templatefile("${path.module}/policies/ecr-push.json", {})
}

resource "aws_iam_policy" "pull" {
  name_prefix = "ecr-pull"
  path        = "/it/docker/"

  policy = templatefile("${path.module}/policies/ecr-pull.json", {})
}

resource "aws_iam_policy" "cleanup" {
  name_prefix = "ecr-cleanup"
  path        = "/it/docker/"

  policy = templatefile("${path.module}/policies/ecr-cleanup.json", {})
}

resource "aws_iam_policy" "deploy" {
  name_prefix = "codedeploy"
  path        = "/it/deploy/"

  policy = templatefile("${path.module}/policies/codedeploy-deploy.json", {
    bucket_name                 = aws_s3_bucket.build_artifact_bucket.bucket
    codedeploy_service_role_arn = aws_iam_role.codedeploy_role.arn
    aws_region                  = data.aws_region.current.name
    account_id                  = data.aws_caller_identity.current.account_id
  })
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
    tomap({ "Application" = "Registration" })
  )
}

resource "aws_ecr_repository" "planorama" {
  name                 = "planorama"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    local.common_tags,
    var.common_tags,
    tomap({ "Application" = "Planorama" })
  )
}

resource "aws_ecr_repository" "conclar" {
  name                 = "conclar"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    local.common_tags,
    var.common_tags,
    tomap({ "Application" = "Conclar" })
  )
}

resource "aws_ecr_lifecycle_policy" "registration" {
  repository = aws_ecr_repository.registration.name
  policy     = templatefile("${path.module}/policies/ecr-lifecycle.json", {})
}
