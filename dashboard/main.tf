variable "project" {
  type = string
}

resource "aws_cloudwatch_dashboard" "ops" {
  dashboard_name = "Operations"
  dashboard_body = templatefile("${path.module}/ops-dash.json", {})
}
