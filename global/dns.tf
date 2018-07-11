# Public DNS
resource "aws_route53_zone" "main" {
  name = "${var.domain_name}"
}

output "name_servers" {
  value = "${aws_route53_zone.main.name_servers}"
}

resource "aws_acm_certificate" "certificate" {
  // We want a wildcard cert so we can host subdomains later.
  domain_name       = "*.${var.domain_name}"
  validation_method = "EMAIL"

  // We also want the cert to be valid for the root domain even though we'll be
  // redirecting to the www. domain immediately.
  subject_alternative_names = ["${var.domain_name}"]
}

