data "aws_ami" "alinux" {
  owners      = ["self", "aws-marketplace", "amazon"]
  most_recent = true

  filter {
    name   = "owner-alias"
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

  # Only allow a subset of image IDs here, so that we don't see churn as we update
  filter {
    name   = "image-id"
    values = ["ami-a9d09ed1", "ami-0e8c04af2729ff1bb"]
  }

}

