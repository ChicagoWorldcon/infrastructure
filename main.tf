resource "aws_vpc" "chicagovpc" {
  cidr_block           = "${local.workspace["vpc_cidr_block"]}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"


  tags = "${merge(
    local.common_tags,
    map("Name", "Chicago 2022")
  )}"
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

  tags = "${merge(
    local.common_tags,
    map("Name", "Public Subnet")
  )}"
}

resource "aws_route_table" "chicago-main" {
  vpc_id                  = "${aws_vpc.chicagovpc.id}"

  tags = "${merge(
    local.common_tags,
    map("Name", "Main Routes")
  )}"
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

  tags = "${local.common_tags}"
}

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.chicagovpc.id}"

  cidr_block = "${local.workspace["public_subnet_cidr"]}"
  availability_zone = "${var.region}a"

  tags = "${merge(
    local.common_tags,
    map("Name", "Public Subnet")
  )}"
}

resource "aws_subnet" "subnet-az-b" {
  vpc_id                  = "${aws_vpc.chicagovpc.id}"
  cidr_block              = "${cidrsubnet("${aws_vpc.chicagovpc.cidr_block}", 8, 1)}"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = "${merge(
    local.common_tags,
    map("Name", "DB Subnet B")
  )}"
}

resource "aws_subnet" "subnet-az-c" {
  vpc_id                  = "${aws_vpc.chicagovpc.id}"
  cidr_block              = "${cidrsubnet("${aws_vpc.chicagovpc.cidr_block}", 8, 2)}"
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = true

  tags = "${merge(
    local.common_tags,
    map("Name", "DB Subnet C")
  )}"

}

resource "aws_subnet" "subnet-az-a" {
  vpc_id                  = "${aws_vpc.chicagovpc.id}"
  cidr_block              = "${cidrsubnet("${aws_vpc.chicagovpc.cidr_block}", 8, 0)}"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = "${merge(
    local.common_tags,
    map("Name", "DB Subnet A")
  )}"
}


