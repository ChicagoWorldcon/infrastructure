provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "us-west-2"
}

variable "domain_name" {
  default = "chicagoworldcon.org"
}

resource "aws_vpc" "vpc-6a628612" {
  cidr_block           = "172.30.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags {
  }
}

resource "aws_internet_gateway" "igw-a5f1adc3" {
  vpc_id = "vpc-6a628612"

  tags {
  }
}

resource "aws_security_group" "vpc-6a628612-rds-launch-wizard" {
    name        = "rds-launch-wizard"
    description = "Created from the RDS Management Console: 2018/07/03 07:05:35"
    vpc_id      = "vpc-6a628612"

    ingress {
        from_port       = 5432
        to_port         = 5432
        protocol        = "tcp"
        cidr_blocks     = ["73.19.44.156/32"]
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "vpc-6a628612-default" {
    name        = "default"
    description = "default VPC security group"
    vpc_id      = "vpc-6a628612"

    ingress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        security_groups = []
        self            = true
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}

