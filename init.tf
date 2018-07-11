terraform {
  backend "s3" {
    bucket = "terraform.offby1.net"
    key    = "chicago/state.tfstate"
    region = "us-west-2"
  }
}
