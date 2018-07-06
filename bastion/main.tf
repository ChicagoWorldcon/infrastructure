## Bastion configuration

# Inputs
## VPC
variable "vpc_id" {}
variable "vpc_cidr_block" {}
variable "bastion_subnet_id" {}
variable "public_key" {}
variable "project" {}
variable "bastion_enabled" {}

data "aws_ami" "alinux" {
  most_recent = true

  filter {
    name = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_instance" "bastion_host" {
  count  = "${var.bastion_enabled}"
  ami           = "${data.aws_ami.alinux.id}"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id = "${var.bastion_subnet_id}"

  vpc_security_group_ids = [
    "${aws_security_group.bastion-sg.id}"
  ]

  key_name = "${aws_key_pair.bastion_key.key_name}"

  tags {
    Name = "bastion"
    Project = "${var.project}"
  }
}

resource "aws_key_pair" "bastion_key" {
  count  = "${var.bastion_enabled}"
  key_name   = "${var.project}-key"
  public_key = "${var.public_key}"

}

resource "aws_security_group" "bastion-sg" {
  name   = "bastion-security-group"
  count  = "${var.bastion_enabled}"
  vpc_id      = "${var.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }
  tags {
    Project = "${var.project}"
  }
}

output "bastion_ip" {
  value = "${join("", aws_instance.bastion_host.*.public_ip)}"
}

output "bastion_security_group_id" {
  value = "${join("", aws_security_group.bastion-sg.*.id)}"
}
