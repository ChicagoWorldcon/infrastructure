terraform {
  backend "s3" {
    bucket = "terraform.chicon.org"
    key    = "state.tfstate"
    region = "us-west-2"
  }
}
