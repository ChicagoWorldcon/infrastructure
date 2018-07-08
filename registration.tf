data "template_file" "script" {
  template = "${file("registration-init.yaml")}"

  vars = {
    db_hostname = "${aws_db_instance.postgresql.address}"
    db_username = "${var.db_username}"
    db_password = "${var.db_password}"
    db_name     = "${var.db_name}"
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

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.alinux.id}"
  instance_type = "t2.medium"

  subnet_id = "${aws_subnet.public.id}"
  vpc_security_group_ids = ["${aws_security_group.web_server_sg.id}"]

  key_name = "${aws_key_pair.reg_system_key.key_name}"

  user_data = "${data.template_cloudinit_config.config.rendered}"

  tags {
    Project = "${var.project}"
    Name = "registration"
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

resource "aws_security_group_rule" "bastion-ingress" {

  count                    = "${var.bastion_enabled}"

  type                     = "ingress"
  security_group_id        = "${aws_security_group.web_server_sg.id}"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  description              = "Security group allowing access from the bastion server"
  source_security_group_id = "${module.bastion_host.bastion_security_group_id}"
}


resource "aws_key_pair" "reg_system_key" {
  key_name   = "${var.project}-registration-key"
  public_key = "${var.public_key}"
}

# Public DNS
resource "aws_route53_zone" "main" {
  name = "${var.domain_name}"
}

output "name_servers" {
  value = "${aws_route53_zone.main.name_servers}"
}

resource "aws_acm_certificate" "certificate" {
  // We want a wildcard cert so we can host subdomains later.
  domain_name       = "*.${var.domain_name}"
  validation_method = "EMAIL"

  // We also want the cert to be valid for the root domain even though we'll be
  // redirecting to the www. domain immediately.
  subject_alternative_names = ["${var.domain_name}"]
}
