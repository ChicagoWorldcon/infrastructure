# Public DNS
resource "aws_route53_zone" "main" {
  name    = var.domain_name
  comment = "${var.project} DNS zone: ${var.role}"
}

resource "namecheap_ns" "main" {
  domain  = var.domain_name
  servers = aws_route53_zone.main.name_servers
}
