output "cloudfront_hostname" {
  value = aws_cloudfront_distribution.site.domain_name
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.site.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.site.bucket
}

output "s3_bucket_cname" {
  value = aws_route53_record.bucket_cname[0].fqdn
}
