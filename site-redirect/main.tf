variable "project" { type = string }
variable "domain_name" { type = string }
variable "target_a_records" { type = list(any) }
variable "target_domain_name" { type = string }

resource "aws_route53_zone" "redirect_zone" {
  name    = var.domain_name
  comment = "${var.project} site redirect zone to ${var.target_domain_name}"
}

resource "aws_route53_record" "redirect_a" {
  zone_id = aws_route53_zone.redirect_zone.zone_id
  name    = ""
  type    = "A"
  ttl     = "300"
  records = var.target_a_records
}

resource "aws_route53_record" "redirect_cname_www" {
  zone_id = aws_route53_zone.redirect_zone.zone_id
  name    = "www.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [var.target_domain_name]
}

resource "namecheap_domain_records" "redirect_zone" {
  domain      = var.domain_name
  mode        = "OVERWRITE"
  nameservers = sort(aws_route53_zone.redirect_zone.name_servers)
}

output "this_zone_id" {
  value = aws_route53_zone.redirect_zone.zone_id
}

output "this_nameservers" {
  value = aws_route53_zone.redirect_zone.name_servers
}
