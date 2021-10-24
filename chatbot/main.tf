variable "project" { type = string }
variable "application" { type = string }
variable "instance_ids" { type = list(string) }
variable "channels" { type = list(string) }

locals {
  event_pattern = jsonencode({
    "source" : ["aws.ec2", "chicon8.test"],
    "detail-type" : ["EC2 Instance State-change Notification"],
    "detail" : {
      "instance-id" : var.instance_ids
    }
  })
}

# This can't wire up the chatbot yet, but it'll set everything else up.
resource "aws_sns_topic" "topic" {
  name = "${var.application}-instance-state-notifications"

  tags = {
    Application = var.application
    Division    = "IT"
    Environment = "global"
    Project     = var.project
  }
}

resource "aws_cloudwatch_event_rule" "rule" {
  name          = "${var.application}-Instance-Watcher"
  event_pattern = local.event_pattern

  tags = {
    Application = var.application
    Division    = "IT"
    Environment = "global"
    Project     = var.project
  }
}

resource "aws_cloudwatch_event_target" "sns-target" {
  rule = aws_cloudwatch_event_rule.rule.name
  arn  = aws_sns_topic.topic.arn
}
