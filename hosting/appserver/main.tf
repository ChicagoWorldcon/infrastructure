locals {
  common_tags = {
    Project     = var.project
    Environment = var.stage
    Application = var.application
    Division    = var.division
  }
}

resource "aws_instance" "web" {
  lifecycle {
    ignore_changes = [user_data, ]
  }

  ami           = data.aws_ami.alinux.id
  instance_type = var.instance_type

  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.security_group_id, aws_security_group.web_server_sg.id]

  key_name = aws_key_pair.reg_system_key.key_name

  user_data = data.template_cloudinit_config.config.rendered

  iam_instance_profile = var.iam_instance_profile

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.stage} ${var.application}" })
  )

  volume_tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.stage} ${var.application}" })
  )
}

resource "aws_ebs_volume" "web" {
  availability_zone = aws_instance.web.availability_zone
  size              = var.volume_size

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.stage} ${var.application}" })
  )
}

resource "aws_volume_attachment" "web" {
  volume_id   = aws_ebs_volume.web.id
  instance_id = aws_instance.web.id
  device_name = "/dev/sda1"
}

resource "aws_eip" "web" {
  instance = aws_instance.web.id
  vpc      = true
  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${var.stage} API server"
    })
  )
}

resource "aws_security_group" "web_server_sg" {
  vpc_id = var.vpc_id

  tags = merge(
    local.common_tags,
    tomap({
      "Name"        = "${var.stage} ${var.application} server",
      "Description" = "Security group for web-server with HTTP ports open within VPC",
    })
  )
}

data "dns_a_record_set" "sendgrid" {
  host = "smtp.sendgrid.com"
}

resource "aws_security_group_rule" "appserver-outbound-smtp" {
  security_group_id = aws_security_group.web_server_sg.id
  description       = "Email server return"
  type              = "egress"
  from_port         = 465
  to_port           = 465
  protocol          = "tcp"
  cidr_blocks       = formatlist("%s/32", data.dns_a_record_set.sendgrid.addrs)
}

resource "aws_security_group_rule" "appserver-inbound-smtp" {
  security_group_id = aws_security_group.web_server_sg.id
  description       = "Email server return"
  type              = "ingress"
  from_port         = 465
  to_port           = 465
  protocol          = "tcp"
  cidr_blocks       = formatlist("%s/32", data.dns_a_record_set.sendgrid.addrs)
}

resource "aws_security_group_rule" "web-inbound-http" {
  security_group_id = aws_security_group.web_server_sg.id
  description       = "Insecure app server - only for https redirect"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web-inbound-https" {
  security_group_id = aws_security_group.web_server_sg.id
  description       = "Secure app server"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web-inbound-ssh" {
  security_group_id = aws_security_group.web_server_sg.id
  description       = "Admin access"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web-outbound-http" {
  security_group_id = aws_security_group.web_server_sg.id
  description       = "Access to port 80 for services"
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web-outbound-https" {
  security_group_id = aws_security_group.web_server_sg.id
  description       = "Access to port 443 for services"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

data "local_file" "public_key" {
  filename = "${var.ssh_key_id}.pub"
}

resource "aws_key_pair" "reg_system_key" {
  key_name   = "${var.project}-${var.stage}-${lower(var.application)}-key"
  public_key = data.local_file.public_key.content
}

resource "aws_cloudwatch_log_group" "registration_group" {
  name              = "${var.application}/${var.stage}"
  retention_in_days = var.log_retention

  tags = merge(
    local.common_tags,
    tomap({
      "Name"        = "${var.stage} hosting logs",
      "Description" = "${var.application} ${var.stage} hosting logs",
    })
  )
}

## Resource policies for cloudwatch logs
resource "aws_iam_role_policy_attachment" "registration-cloudwatch" {
  role = var.iam_role_name

  policy_arn = data.aws_iam_policy.CloudWatchAgentServerPolicy.arn
}

data "aws_iam_policy" "AmazonEC2RoleforSSM" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "aws_iam_policy" "CloudWatchAgentServerPolicy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
