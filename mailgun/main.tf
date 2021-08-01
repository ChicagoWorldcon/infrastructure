# Mailgun domain configuration

variable "dns_zone_id" { type = string }
variable "mail_domain" { type = string }

resource "aws_route53_record" "verification_1" {
  zone_id = var.dns_zone_id
  name    = var.mail_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:mailgun.org ~all"]
}


resource "aws_route53_record" "verification_2" {
  zone_id = var.dns_zone_id
  name    = "smtp._domainkey.${var.mail_domain}"
  type    = "TXT"
  ttl     = "600"
  records = ["k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDTq+7rDI+Tanprfui1JXga9RQCQQPL2ShT1HywrbPsWRRC9TrijfiZknGlI3cyCaYXtJKRw2Qio7FViJrKxq5CHNF+tNljE53vNIOjC6AQFSaaLgux8VpS1PntQPDI4osWO1lIYz8osttQ6BAKjiyez7w2GF3yjAtdEPEzi8DWsQIDAQAB"]
}

resource "aws_route53_record" "mx" {
  zone_id = var.dns_zone_id
  name    = "comms.chicon.org"
  type    = "MX"
  ttl     = "300"
  records = [
    "10 mxa.mailgun.org",
    "10 mxb.mailgun.org",
  ]
}

resource "aws_route53_record" "tracking" {
  zone_id = var.dns_zone_id
  name    = "email.${var.mail_domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["mailgun.org"]
}
