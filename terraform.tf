resource "aws_vpc" "chicagovpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags {
    Name    = "Chicago 2022"
    Project = "${var.project}"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id = "${aws_vpc.chicagovpc.id}"
  service_name = "com.amazonaws.us-west-2.s3"
}

resource "aws_route_table" "chicago-public" {
  vpc_id                  = "${aws_vpc.chicagovpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.chicago-gateway.id}"
  }

  tags {
    Project = "${var.project}"
    Name = "Public Subnet"
  }
}

resource "aws_route_table" "chicago-main" {
  vpc_id                  = "${aws_vpc.chicagovpc.id}"

  tags {
    Project = "${var.project}"
    Name = "Main Routes"
  } 
}

resource "aws_main_route_table_association" "chicago-vpc" {
  vpc_id                  = "${aws_vpc.chicagovpc.id}"
  route_table_id          = "${aws_route_table.chicago-main.id}"
}

resource "aws_route_table_association" "chicago-public" {
  subnet_id               = "${aws_subnet.public.id}"
  route_table_id          = "${aws_route_table.chicago-public.id}"
}

resource "aws_internet_gateway" "chicago-gateway" {
  vpc_id                  = "${aws_vpc.chicagovpc.id}"

  tags {
    Project = "${var.project}"
  }
}

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.chicagovpc.id}"

  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "${var.region}a"

  tags {
    Project = "${var.project}"
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "subnet-az-b" {
    vpc_id                  = "${aws_vpc.chicagovpc.id}"
    cidr_block              = "172.30.1.0/24"
    availability_zone       = "${var.region}b"
    map_public_ip_on_launch = true

    tags {
      Name = "DB Subnet B"
      Project = "${var.project}"
    }
}

resource "aws_subnet" "subnet-az-c" {
    vpc_id                  = "${aws_vpc.chicagovpc.id}"
    cidr_block              = "172.30.2.0/24"
    availability_zone       = "${var.region}c"
    map_public_ip_on_launch = true

    tags {
      Name = "DB Subnet C"
      Project = "${var.project}"
    }
}

resource "aws_subnet" "subnet-az-a" {
    vpc_id                  = "${aws_vpc.chicagovpc.id}"
    cidr_block              = "172.30.0.0/24"
    availability_zone       = "${var.region}a"
    map_public_ip_on_launch = true

    tags {
      Name = "DB Subnet A"
      Project = "${var.project}"
    }
}


module "bastion_host" {
  source = "./bastion"

  bastion_enabled = "${var.bastion_enabled}"

  vpc_id = "${aws_vpc.chicagovpc.id}"
  vpc_cidr_block = "${var.vpc_cidr_block}"
  bastion_subnet_id = "${aws_subnet.public.id}"

  public_key = "${data.local_file.public_key.content}"

  project = "${var.project}"
}
