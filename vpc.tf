module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "chicon-vpc"
  cidr = "172.42.0.0/16"

  # Subnet structure
  azs              = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets  = ["172.42.1.0/24", "172.42.2.0/24", "172.42.3.0/24"]
  public_subnets   = ["172.42.11.0/24", "172.42.12.0/24", "172.42.13.0/24"]
  database_subnets = ["172.42.21.0/24", "172.42.22.0/24", "172.42.23.0/24"]

  # cheaper NAT
  single_nat_gateway     = true
  enable_nat_gateway     = false
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_s3_endpoint   = true

  tags = merge(
    local.common_tags,
    map("Terraform", "true", "Department", "IT")
  )
}

