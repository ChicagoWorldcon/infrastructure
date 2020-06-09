# Public DNS
resource "aws_route53_zone" "main" {
  name    = var.domain_name
  comment = "${var.project} DNS zone: ${var.role}"
}

