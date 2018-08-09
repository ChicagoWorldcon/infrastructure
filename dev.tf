locals {
  dev = {
    dev = {
      reg-www = "registration-dev"
      reg-api = "api-dev"
      vpc_cidr_block = "172.30.0.0/16"
      public_subnet_cidr = "172.30.100.0/24"

      # instance distinguishers
      instance_prompt_colour = "34"
    }
  }
}
