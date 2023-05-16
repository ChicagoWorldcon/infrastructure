locals {
  tags = var.common_tags
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "site" {
  bucket        = var.bucket_name
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = local.tags
}

resource "aws_s3_bucket_acl" "site" {
  bucket = aws_s3_bucket.site.id
  acl    = "private"
}

resource "aws_cloudfront_distribution" "site" {
  depends_on = [aws_s3_bucket.site]
  comment    = var.cf_distribution_comment

  origin {
    // Important to use this format of origin domain name, it is the only format that
    // supports S3 redirects with CloudFront
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
    origin_path              = var.origin_path
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
    target_origin_id = aws_s3_bucket.site.bucket_regional_domain_name

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

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "access-${var.bucket_name}"
  description                       = "Access to ${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.site.id
  policy = templatefile("${path.module}/templates/bucket-policy.json", {
    bucket_name                 = var.bucket_name
    cloudfront_distribution_arn = aws_cloudfront_distribution.site.arn
  })
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_route53_record" "bucket_cname" {
  count   = length(var.aliases)
  zone_id = var.dns_zone_id
  name    = element(var.aliases, count.index)
  type    = "CNAME"
  ttl     = 300
  records = [aws_cloudfront_distribution.site.domain_name]
}
