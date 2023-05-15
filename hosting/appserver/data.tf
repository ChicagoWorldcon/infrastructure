# data "aws_ami" "alinux" {
#   owners      = ["self", "aws-marketplace", "amazon", "099720109477"]
#   most_recent = true

#   # filter {
#   #   name   = "owner-alias"
#   #   values = ["canonical"]
#   # }

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-*"]
#   }

#   # filter {
#   #   name   = "virtualization-type"
#   #   values = ["hvm"]
#   # }

#   # Only allow a subset of image IDs here, so that we don't see churn as we update
#   filter {
#     name   = "image-id"
#     values = ["ami-043505d1b57b5d3e3", "ami-05e59a82236d456d9"]
#   }

# }
