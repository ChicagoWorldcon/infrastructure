variable "ssh_key_id" {}

data "template_file" "script" {
  template = "${file("scripts/registration-init.yaml")}"

  vars = {
    project              = "${var.project}"
    db_hostname          = "${aws_db_instance.reg-db.address}"
    db_username          = "${var.db_username}"
    db_admin_username    = "${var.db_admin_username}"
    db_name              = "${var.db_name}"
    stage                = "${local.stage}"
    aws_region           = "${var.region}"

    # base64-encoded file blobs for system files
    letsencrypt_service  = "${base64encode("${data.template_file.letsencrypt_service.rendered}")}"
    letsencrypt_timer    = "${base64encode(file("scripts/letsencrypt.timer"))}"
    registration_service = "${base64encode("${data.template_file.registration_service.rendered}")}"
    service_env_vars     = "${base64encode("${data.template_file.service_env_vars_script.rendered}")}"
    service_env_file     = "${base64encode("${data.template_file.service_env_vars_file.rendered}")}"
    db_env_vars          = "${base64encode("${data.template_file.db_env_vars_script.rendered}")}"
    docker_daemon_json   = "${base64encode("${data.template_file.docker_daemon_json.rendered}")}"
    prompt_file          = "${base64encode("${data.template_file.shell_prompt.rendered}")}"
  }
}

data "template_file" "letsencrypt_service" {
  template = "${file("scripts/letsencrypt.service")}"

  vars = {
    domain_name = "${var.domain_name}"
    admin_email = "chicago@offby1.net"
    test_cert   = "${local.test_cert_flag}"
  }
}

data "template_file" "registration_service" {
  template = "${file("scripts/registration.service")}"

  vars = {
    db_hostname = "${aws_db_instance.reg-db.address}"
    db_name              = "${var.db_name}"
    registration_api_domain_name = "${local.workspace["reg-api"]}.${var.domain_name}"
    registration_www_domain_name = "${local.workspace["reg-www"]}.${var.domain_name}"
  }
}

data "template_file" "service_env_vars_script" {
  template = "${file("scripts/service-env-vars.sh")}"

  vars = {
    export                       = "export "
    project                      = "${var.project}"
    registration_api_domain_name = "${local.workspace["reg-api"]}.${var.domain_name}"
    registration_www_domain_name = "${local.workspace["reg-www"]}.${var.domain_name}"
    db_hostname                  = "${aws_db_instance.reg-db.address}"
    db_username                  = "${var.db_username}"
    db_admin_username            = "${var.db_admin_username}"
    db_name                      = "${var.db_name}"
    stage                        = "${local.stage}"
    aws_region                   = "${var.region}"

    session_secret               = "${data.aws_secretsmanager_secret.session_secret.name}"
    jwt_secret                   = "${data.aws_secretsmanager_secret.jwt_secret.name}"
    sendgrid_api_key             = "${data.aws_secretsmanager_secret.sendgrid_api_key_secret.name}"
  }
}

data "template_file" "service_env_vars_file" {
  template = "${file("scripts/service-env-vars.sh")}"

  vars = {
    export                       = ""
    project                      = "${var.project}"
    registration_api_domain_name = "${local.workspace["reg-api"]}.${var.domain_name}"
    registration_www_domain_name = "${local.workspace["reg-www"]}.${var.domain_name}"
    db_hostname                  = "${aws_db_instance.reg-db.address}"
    db_username                  = "${var.db_username}"
    db_admin_username            = "${var.db_admin_username}"
    db_name                      = "${var.db_name}"
    stage                        = "${local.stage}"
    aws_region                   = "${var.region}"

    session_secret               = "${data.aws_secretsmanager_secret.session_secret.name}"
    jwt_secret                   = "${data.aws_secretsmanager_secret.jwt_secret.name}"
    sendgrid_api_key             = "${data.aws_secretsmanager_secret.sendgrid_api_key_secret.name}"
  }
}

data "template_file" "db_env_vars_script" {
  template = "${file("scripts/db-env-vars.sh")}"

  vars = {
    project           = "${var.project}"
    db_hostname       = "${aws_db_instance.reg-db.address}"
    db_username       = "${var.db_username}"
    db_admin_username = "${var.db_admin_username}"
    db_name           = "${var.db_name}"
    stage             = "${local.stage}"
  }
}

data "template_cloudinit_config" "config" {
  gzip = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = "${data.template_file.script.rendered}"
  }
}

data "template_file" "db_init" {
  template = "${file("db_init/00-setup-rds.sql")}"

  vars = {
    db_admin_password = "${data.aws_secretsmanager_secret_version.db_superuser_password.secret_string}"
    db_name           = "${var.db_name}"
  }
}

data "template_file" "docker_daemon_json" {
  template = "${file("scripts/daemon.json")}"

  vars = {
    log_group = "${aws_cloudwatch_log_group.registration_group.name}"
  }
}

data "template_file" "shell_prompt" {
  template = "${file("scripts/set-instance-prompt.sh")}"

  vars = {
    colour_code = "${local.instance_prompt_colour}"
  }
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.alinux.id}"
  instance_type = "t2.medium"

  subnet_id = "${aws_subnet.public.id}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.web_server_sg.id}"]

  key_name = "${aws_key_pair.reg_system_key.key_name}"

  user_data = "${data.template_cloudinit_config.config.rendered}"

  iam_instance_profile = "${module.creds.registration_iam_instance_profile_id}"

  connection {
    type = "ssh"
    user = "ec2-user"
    host = "${self.public_dns}"
    agent_identity = "${var.ssh_key_id}"
  }

  provisioner "remote-exec" {
    inline = [
      "set -x",
      "sudo mkdir -p /postgres/init.d/${var.db_username}",
      "sudo mkdir -p /postgres/init.d/admin",
      "sudo mkdir -p /opt/letsencrypt/etc /opt/letsencrypt/lib",
      "sudo chown -R ec2-user /postgres/init.d /opt/letsencrypt",

      "sudo systemctl start letsencrypt.timer",
      "sudo systemctl enable letsencrypt.timer",
      "sudo systemctl enable registration.service",
    ]

  }

  provisioner "file" {
    content = "${data.template_file.db_init.rendered}"
    destination = "/postgres/init.d/${var.db_username}/00-setup-rds.sql"

  }

  provisioner "file" {
    source = "../registration-api/postgres/init/"
    destination = "/postgres/init.d/admin"

  }

  provisioner "remote-exec" {
    script = "${local_file.codedeploy_script.filename}"
  }

  tags = "${merge(
    local.common_tags,
    map("Name", "registration")
  )}"

}

data "template_file" "codedeploy_script" {
  template = "${file("scripts/install-codedeploy.sh")}"

  vars = {
    codedeploy_agent_s3_bucket = "${local.codedeploy_bucket}.s3.amazonaws.com"
  }
}

resource "local_file" "codedeploy_script" {
  content = "${data.template_file.codedeploy_script.rendered}"
  filename = "${path.module}/tmp-install-codedeploy.sh"
}

resource "aws_eip" "web" {
  instance = "${aws_instance.web.id}"
  vpc = true
}

resource "aws_security_group" "web_server_sg" {
  vpc_id      = "${aws_vpc.chicagovpc.id}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "web-server",
      "Description", "Security group for web-server with HTTP ports open within VPC",
    )
  )}"
}

resource "aws_security_group_rule" "web-inbound-http" {
  security_group_id = "${aws_security_group.web_server_sg.id}"
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web-inbound-https" {
  security_group_id = "${aws_security_group.web_server_sg.id}"
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web-inbound-ssh" {
  security_group_id = "${aws_security_group.web_server_sg.id}"
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web-outbound-db" {
  security_group_id = "${aws_security_group.web_server_sg.id}"
  type = "egress"
  from_port = 5432
  to_port = 5432
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.postgresql.id}"
}

resource "aws_security_group_rule" "web-outbound-http" {
  security_group_id = "${aws_security_group.web_server_sg.id}"
  type = "egress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web-outbound-https" {
  security_group_id = "${aws_security_group.web_server_sg.id}"
  type = "egress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

data "local_file" "public_key" {
  filename = "${var.ssh_key_id}.pub"
}

resource "aws_key_pair" "reg_system_key" {
  key_name   = "${var.project}-${local.stage}-registration-key"
  public_key = "${data.local_file.public_key.content}"
}

resource "aws_route53_record" "a_record_org" {
  zone_id = "${data.terraform_remote_state.global.dns_zone_id}"
  name    = "${local.workspace["reg-api"]}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = ["${aws_eip.web.public_ip}"]
}

resource "aws_cloudwatch_log_group" "registration_group" {
  name = "Registration/${local.stage}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "registration-logs",
      "Description", "Registration API logs",
    )
  )}"
}

## Resource policies for cloudwatch logs
resource "aws_iam_role_policy_attachment" "registration-cloudwatch" {
  role = "${module.creds.registration_iam_role_name}"

  policy_arn = "${data.aws_iam_policy.CloudWatchAgentServerPolicy.arn}"
}

