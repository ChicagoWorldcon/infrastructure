locals {
  prod = {
    prod = {
      reg-www = "registration"
      reg-api = "api"
      admin-www = "registration-admin"
      vpc_cidr_block = "172.42.0.0/16"
      public_subnet_cidr = "172.42.100.0/24"

      # instance distinguishers
      instance_prompt_colour = "31"
    }
  }
}
