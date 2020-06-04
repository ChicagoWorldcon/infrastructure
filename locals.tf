locals {
  common_tags = {
    Project = "${var.project}"
  }

  vpc_cidr_block = "172.42.0.0/16"
}

