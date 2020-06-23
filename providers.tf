provider "aws" {
  version = "~> 2.60"
  profile = "chicago-bid"
  region  = "us-west-2"
}

provider "local" {
  version = "~> 1.4"
}

provider "template" {
  version = "~> 2.1"
}
