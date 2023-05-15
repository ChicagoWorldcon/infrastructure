locals {
  tags = var.common_tags
}

resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name
  acl    = "public-read"
  policy = templatefile("${path.module}/templates/bucket-policy.json", {
    bucket_name = var.bucket_name
  })
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = local.tags
}

resource "aws_cloudfront_distribution" "site" {
  depends_on = [aws_s3_bucket.site]
  comment    = var.cf_distribution_comment

  origin {
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    // Important to use this format of origin domain name, it is the only format that
    // supports S3 redirects with CloudFront
    domain_name = aws_s3_bucket.site.bucket_regional_domain_name
    // domain_name = "${var.bucket_name}.s3-website-${var.aws_region}.amazonaws.com"

    origin_id   = var.s3_origin_id
    origin_path = var.origin_path
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = var.aliases

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"

    // Using CloudFront defaults, tune to liking
    min_ttl     = var.cf_min_ttl
    default_ttl = var.cf_default_ttl
    max_ttl     = var.cf_max_ttl
  }

  price_class = var.cf_price_class

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = local.tags
}

resource "aws_route53_record" "bucket_cname" {
  count   = length(var.aliases)
  zone_id = var.dns_zone_id
  name    = element(var.aliases, count.index)
  type    = "CNAME"
  ttl     = 300
  records = [aws_cloudfront_distribution.site.domain_name]
}
