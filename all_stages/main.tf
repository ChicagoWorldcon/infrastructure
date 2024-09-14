locals {
  certificate_sans = distinct(concat([var.domain_name], var.subject_alternative_names))
  # zone mappings. If the zone is in var.san_zone_mapping, we'll use that zone ID, otherwise
  # we will use data.aws_route53_zone.zone.zone_id
  zone_ids = {
    for zone in local.certificate_sans : zone => lookup(var.san_zone_mapping, zone, data.aws_route53_zone.zone.zone_id)
  }
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
  subject_alternative_names = local.certificate_sans
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
  zone_id         = lookup(local.zone_ids, each.value.name, data.aws_route53_zone.zone.zone_id)
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
