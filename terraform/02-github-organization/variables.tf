# GitHub Authentication
variable "github_token" {
  description = "GitHub Personal Access Token with organization admin permissions"
  type        = string
  sensitive   = true
}

variable "github_organization" {
  description = "GitHub organization name"
  type        = string
}

# Organization Teams
variable "organization_teams" {
  description = "Map of teams to create in the organization"
  type = map(object({
    name        = string
    description = string
    privacy     = string # "secret" or "closed"
  }))
  default = {}
}

# Organization Secrets
variable "organization_secrets" {
  description = "Map of organization secrets for GitHub Actions"
  type = map(object({
    value      = string
    visibility = string # "all", "private", "selected"
  }))
  default = {}
  sensitive = true
}

# Organization Variables
variable "organization_variables" {
  description = "Map of organization variables for GitHub Actions"
  type = map(object({
    value      = string
    visibility = string # "all", "private", "selected"
  }))
  default = {}
}

 

