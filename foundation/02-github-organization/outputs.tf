output "organization_teams" {
  description = "List of organization teams"
  value = {
    for team_name, team in github_team.teams : team_name => {
      id          = team.id
      name        = team.name
      description = team.description
      privacy     = team.privacy
    }
  }
}

output "organization_secrets" {
  description = "List of organization secrets (names only)"
  value = sort(
    [
      github_actions_organization_secret.spaces_access_key_ci.secret_name,
      github_actions_organization_secret.spaces_secret_key_ci.secret_name
    ]
  )
  sensitive = true
}

output "organization_variables" {
  description = "List of organization variables"
  value = {
    for var_name, variable in github_actions_organization_variable.variables : var_name => {
      value      = variable.value
      visibility = variable.visibility
    }
  }
}

