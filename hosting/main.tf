module "dev-secrets" {
  source  = "./secrets/"
  project = var.project
  stage   = "dev"

  common_tags = {
    Division = "IT"
  }
}

module "staging-secrets" {
  source  = "./secrets/"
  project = var.project
  stage   = "staging"

  common_tags = {
    Division = "IT"
  }
}

module "prod-secrets" {
  source  = "./secrets/"
  project = var.project
  stage   = "prod"

  common_tags = {
    Division = "IT"
  }
}


