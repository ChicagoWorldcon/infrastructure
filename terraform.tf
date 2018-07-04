resource "aws_vpc" "chicagovpc" {
  cidr_block           = "172.30.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags {
    Project = "${var.project}"
  }
}

resource "aws_route_table" "chicago-routes" {
  vpc_id                  = "${aws_vpc.chicagovpc.id}"

  tags {
    Project = "${var.project}"
  }
}

resource "aws_internet_gateway" "chicago-gateway" {
  vpc_id                  = "${aws_vpc.chicagovpc.id}"

  tags {
    Project = "${var.project}"
  }
}

resource "aws_route" "chicago-routes" {
  route_table_id          = "${aws_route_table.chicago-routes.id}"

  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = "${aws_internet_gateway.chicago-gateway.id}"
}

resource "aws_main_route_table_association" "chicago-routes" {
  vpc_id                  = "${aws_vpc.chicagovpc.id}"
  route_table_id          = "${aws_route_table.chicago-routes.id}"
}

resource "aws_subnet" "subnet-az-b" {
    vpc_id                  = "${aws_vpc.chicagovpc.id}"
    cidr_block              = "172.30.1.0/24"
    availability_zone       = "${var.region}b"
    map_public_ip_on_launch = true

    tags {
      Project = "${var.project}"
    }
}

resource "aws_subnet" "subnet-az-c" {
    vpc_id                  = "${aws_vpc.chicagovpc.id}"
    cidr_block              = "172.30.2.0/24"
    availability_zone       = "${var.region}c"
    map_public_ip_on_launch = true

    tags {
      Project = "${var.project}"
    }
}

resource "aws_subnet" "subnet-az-a" {
    vpc_id                  = "${aws_vpc.chicagovpc.id}"
    cidr_block              = "172.30.0.0/24"
    availability_zone       = "${var.region}a"
    map_public_ip_on_launch = true

    tags {
      Project = "${var.project}"
    }
}

## Bastion configuration
resource "aws_instance" "bastion" {
  ami           = "${data.aws_ami.alinux.id}"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.subnet-az-a.id}"

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
  key_name   = "void"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPFVzh209FernGTIhQ23FweaV5dC1rIekwSDiWIsO2AOq3SVpmthvkbnsW4WpbJw0AEa92h9iItCvdw+qvEJ0M3UNyti8FO/wfdQafb4oXS9J3uyqZXfZ+uiWeTrszv3CmFFy9i+vVYhOIMM8T0PtXJF+ewUa9DRppTI5c+Ujiw/jjL73Z+0697Bg2J+raee/wJXZWHhMcvA5/A7kehXhyDR17apX2xhHtdey+bW/LEWki1vMCh7g2Jl+6u9BcvPJsQUe42XRTmK9qK/kkwNmEmaosGyZlJNaksutSpqRbKshbg6pyZwMDM9oB5j8aZdmX2BYQ28O3rOgZA+u8pB39 offby1@Chriss-MacBook-Pro.local"

}

resource "aws_security_group" "bastion-sg" {
  name   = "bastion-security-group"
  vpc_id      = "${aws_vpc.chicagovpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Project = "${var.project}"
  }
}

output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}
