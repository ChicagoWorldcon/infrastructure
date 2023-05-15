terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "project" { type = string }

locals {
  common_tags = {
    Project     = var.project
    ServiceName = "ChicagoRegistration"
  }
}

# resource "digitalocean_spaces_bucket" "hugo-host" {
#   name   = "chicon8-hugo-content"
#   region = "nyc3"
# }

resource "aws_secretsmanager_secret" "spaces_api_token_staging" {
  name = "${var.project}/storage/staging"

  tags = merge(
    local.common_tags,
    tomap({
      "Environment" = "staging"
      "Name"        = "Staging API access token for Hugos",
    })
  )
}
resource "aws_secretsmanager_secret" "spaces_api_token_prod" {

  name = "${var.project}/storage/prod"

  tags = merge(
    local.common_tags,
    tomap({
      "Environment" = "prod",
      "Name"        = "Prod API access token for Hugos",
    })
  )
}

output "api_secrets" {
  value = {
    prod    = aws_secretsmanager_secret.spaces_api_token_prod.name
    staging = aws_secretsmanager_secret.spaces_api_token_staging.name
  }
}
