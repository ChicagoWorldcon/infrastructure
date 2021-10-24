variable "application" { type = string }
variable "project" { type = string }
variable "instance_map" { type = map(string) }
variable "sns_topic_arn" { type = string }

resource "aws_cloudwatch_metric_alarm" "alarm_map" {
  for_each            = var.instance_map
  alarm_name          = "${var.application}-${each.key}-StatusCheckFailed"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = 2
  evaluation_periods  = 3
  period              = 300
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "${var.application} ${each.key} instance status check"
  dimensions = {
    InstanceId = each.value
  }
  alarm_actions = [var.sns_topic_arn]
}
