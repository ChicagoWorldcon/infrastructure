variable "db_name" {}
variable "project" {}
variable "stage" {}

variable "route53_zone_id" {}
variable "codedeploy_bucket" {}
variable "codepipeline_bucket" {}

variable "common_tags" {
  default = {}
}
