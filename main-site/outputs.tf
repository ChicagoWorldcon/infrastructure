output "cloudfront_hostname" {
  value = aws_cloudfront_distribution.site.domain_name
}

output "cloudfront_hosted_zone_id" {
  value = aws_cloudfront_distribution.site.hosted_zone_id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.site.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.site.bucket
}

