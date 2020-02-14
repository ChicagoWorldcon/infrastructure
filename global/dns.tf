# Public DNS
resource "aws_route53_zone" "main" {
  name = var.domain_name
}

output "name_servers" {
  value = aws_route53_zone.main.name_servers
}

output "dns_zone_id" {
  value = aws_route53_zone.main.zone_id
}
