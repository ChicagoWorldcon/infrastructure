// Provider vars for authentication
variable "aliases" {
  description = "List of hostnames to serve site on. E.g. with and without www"
  type        = list(any)
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  description = "Name of bucket to be created in S3. Must be globally unique."
  type        = string
}

variable "dns_zone_id" {
  description = "DNS zone ID for the site CNAMEs"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of an ACM certificate in us-east-1"
  type        = string
}

variable "cf_distribution_comment" {
  description = "Display comment for the CF distribution"
  type        = string
  default     = ""
}

variable "cf_default_ttl" {
  description = "CloudFront default TTL for cachine"
  type        = string
  default     = "0"
}

variable "cf_min_ttl" {
  description = "CloudFront minimum TTL for caching"
  type        = string
  default     = "0"
}

variable "cf_max_ttl" {
  description = "CloudFront maximum TTL for caching"
  type        = string
  default     = "31536000"
}

variable "cf_price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_All"
}

variable "origin_path" {
  description = "Path in S3 bucket for hosted files, without slashes"
  type        = string
  default     = "/public"
}

variable "s3_origin_id" {
  description = "Origin ID used in CloudFront"
  type        = string
  default     = "site-s3-origin"
}
