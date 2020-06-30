# Create the resources that all stages need.
resource "aws_secretsmanager_secret" "db_superuser_password" {
  name = "${var.project}/db/db_superuser_password"

  tags = merge(
    var.common_tags,
    map(
      "Name", "DB Superuser",
      "ServiceName", "ChicagoAdmin"
    )
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
  name    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.zone.zone_id
  records = [aws_acm_certificate.certificate.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

