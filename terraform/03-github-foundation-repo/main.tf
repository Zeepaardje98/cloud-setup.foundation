terraform {
  required_version = ">= 1.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
  backend "s3" {}
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

resource "github_repository" "foundation" {
  name        = var.repository_name
  description = var.repository_description

  visibility = var.repository_visibility
  auto_init  = var.auto_init
  topics     = var.topics

  template {
    owner      = var.template_owner
    repository = var.template_repository
  }
}


