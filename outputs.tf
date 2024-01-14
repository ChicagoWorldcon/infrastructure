output "global_ns" {
  value = data.aws_route53_zone.chicon.name_servers
}
