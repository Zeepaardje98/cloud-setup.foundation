# GitHub Authentication
variable "github_token" {
  description = "GitHub Personal Access Token with organization admin permissions."
  type        = string
  sensitive   = true
}

variable "github_organisation" {
  description = "GitHub organization name."
  type        = string
}

