output "name_servers" {
  value = aws_route53_zone.main.name_servers
}

output "dns_zone_id" {
  value = aws_route53_zone.main.zone_id
}
