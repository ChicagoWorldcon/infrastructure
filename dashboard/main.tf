variable "project" {
  type = string
}

data "template_file" "ops" {
  template = file("${path.module}/ops-dash.json")
}

resource "aws_cloudwatch_dashboard" "ops" {
  dashboard_name = "Operations"
  dashboard_body = data.template_file.ops.rendered
}
