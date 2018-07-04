resource "aws_instance" "web" {
  ami           = "${data.aws_ami.alinux.id}"
  instance_type = "t2.medium"

  subnet_id = "${aws_subnet.subnet-az-a.id}"
  vpc_security_group_ids = ["${module.web_server_sg.this_security_group_id}"]

  tags {
    Project = "${var.project}"
    Name = "registration"
  }
}

module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = "${aws_vpc.chicagovpc.id}"

  ingress_cidr_blocks = ["10.10.0.0/16"]
}
