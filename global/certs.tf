provider "aws" {
  profile = "chicago"
  region = "us-east-1"
  alias = "us-east-1"
}

// Use the AWS Certificate Manager to create an SSL cert for our domain.
// This resource won't be created until you receive the email verifying you
// own the domain and you click on the confirmation link.
resource "aws_acm_certificate" "certificate" {
  provider = "aws.us-east-1"

  // We want a wildcard cert so we can host subdomains later.
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"

  tags {
    Project = "${var.project}"
    Name = "chicagoworldcon.org"
    Environment = "global"
  } 
  
  lifecycle {
    create_before_destroy = true
  }

  // We also want the cert to be valid for the root domain even though we'll be
  // redirecting to the www. domain immediately.
  subject_alternative_names = ["${var.domain_name}"]
}

output "certificate_arn" {
  value = "${aws_acm_certificate.certificate.arn}"
}
