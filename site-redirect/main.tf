variable "project" { type = string }
variable "domain_name" { type = string }
variable "target_a_records" {
  type    = list(any)
  default = []
}
variable "target_domain_name" { type = string }
variable "target_zone_id" { type = string }

resource "aws_route53_zone" "redirect_zone" {
  name    = var.domain_name
  comment = "${var.project} site redirect zone to ${var.target_domain_name}"
}

resource "aws_route53_record" "redirect_alias" {
  zone_id = aws_route53_zone.redirect_zone.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = var.target_domain_name
    zone_id                = var.target_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "redirect_cname_www" {
  zone_id = aws_route53_zone.redirect_zone.zone_id
  name    = "www.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [var.target_domain_name]
}

output "this_zone_id" {
  value = aws_route53_zone.redirect_zone.zone_id
}

output "this_nameservers" {
  value = aws_route53_zone.redirect_zone.name_servers
}
