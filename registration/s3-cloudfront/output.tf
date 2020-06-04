output "cloudfront_hostname" {
  value = "${aws_cloudfront_distribution.hugo.domain_name}"
}

output "s3_bucket_arn" {
  value = "${aws_s3_bucket.hugo.arn}"
}

output "s3_bucket_name" {
  value = "${aws_s3_bucket.hugo.bucket}"
}
