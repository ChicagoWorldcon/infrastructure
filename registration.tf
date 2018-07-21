variable "ssh_key_id" {}

data "template_file" "script" {
  template = "${file("registration-init.yaml")}"

  vars = {
    project     = "${var.project}"
    db_hostname = "${aws_db_instance.reg-db.address}"
    db_username = "${var.db_username}"
    db_admin_username = "${var.db_admin_username}"
    db_name     = "${var.db_name}"
    stage       = "${terraform.workspace}"

    # base64-encoded file blobs for system files
    letsencrypt_service = "${base64encode("${data.template_file.letsencrypt_service.rendered}")}"
    letsencrypt_timer   = "${base64encode(file("scripts/letsencrypt.timer"))}"
    service_env_vars    = "${base64encode("${data.template_file.service_env_vars_script.rendered}")}"
    db_env_vars         = "${base64encode("${data.template_file.db_env_vars_script.rendered}")}"
  }
}

data "template_file" "letsencrypt_service" {
  template = "${file("scripts/letsencrypt.service")}"

  vars = {
    domain_name = "${var.domain_name}"
    admin_email = "chicago@offby1.net"
  }
}

data "template_file" "service_env_vars_script" {
  template = "${file("scripts/service-env-vars.sh")}"

  vars = {
    project     = "${var.project}"
    registration_domain_name = "${var.reg-www}.${var.domain_name}"
    db_hostname = "${aws_db_instance.reg-db.address}"
    db_username = "${var.db_username}"
    db_admin_username = "${var.db_admin_username}"
    db_name     = "${var.db_name}"
    stage       = "${terraform.workspace}"
  }
}

data "template_file" "db_env_vars_script" {
  template = "${file("scripts/db-env-vars.sh")}"

  vars = {
    project     = "${var.project}"
    db_hostname = "${aws_db_instance.reg-db.address}"
    db_username = "${var.db_username}"
    db_admin_username = "${var.db_admin_username}"
    db_name     = "${var.db_name}"
    stage       = "${terraform.workspace}"
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
    db_admin_password = "${var.db_superuser_password}"
    db_name           = "${var.db_name}"
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

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /postgres/init.d/${var.db_username}",
      "sudo mkdir -p /postgres/init.d/admin",
      "sudo mkdir -p /opt/letsencrypt/etc /opt/letsencrypt/lib",
      "sudo chown -R ec2-user /postgres/init.d /opt/letsencrypt",

      "sudo systemctl start letsencrypt.timer",
      "sudo systemctl enable letsencrypt.timer",
    ]

    connection {
      type = "ssh"
      user = "ec2-user"
      host = "${self.public_dns}"
      agent_identity = "${var.ssh_key_id}"
    }
  }

  provisioner "file" {
    content = "${data.template_file.db_init.rendered}"
    destination = "/postgres/init.d/${var.db_username}/00-setup-rds.sql"

    connection {
      type = "ssh"
      user = "ec2-user"
      host = "${self.public_dns}"
      agent_identity = "${var.ssh_key_id}"
    }
  }

  provisioner "file" {
    source = "../registration-api/postgres/init/"
    destination = "/postgres/init.d/admin"

    connection {
      type = "ssh"
      user = "ec2-user"
      host = "${self.public_dns}"
      agent_identity = "${var.ssh_key_id}"
    }
  }

  tags {
    Project = "${var.project}"
    Name = "registration"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_eip" "web" {
  instance = "${aws_instance.web.id}"
  vpc = true
}

resource "aws_security_group" "web_server_sg" {
  vpc_id      = "${aws_vpc.chicagovpc.id}"

  tags {
    Project = "${var.project}"
    Name = "web-server"
    Description = "Security group for web-server with HTTP ports open within VPC"
    Environment = "${terraform.workspace}"
  }
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
  key_name   = "${var.project}-registration-key"
  public_key = "${data.local_file.public_key.content}"
}

resource "aws_route53_record" "a_record_org" {
  zone_id = "${data.terraform_remote_state.global.dns_zone_id}"
  name    = "${var.reg-www}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = ["${aws_eip.web.public_ip}"]
}
