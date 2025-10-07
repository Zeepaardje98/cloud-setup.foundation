#!/usr/bin/env bash
set -euo pipefail

# Common Terraform helper functions for apply scripts

# check_aws_credentials AWS_CREDENTIALS_FILE AWS_PROFILE
# Returns 0 if credentials file exists and contains the profile, else 1
check_aws_credentials() {
  local credentials_file="$1"
  local profile_name="$2"

  echo "[INFO] Checking if AWS credentials exist with DigitalOcean Spaces profile."

  if [[ -f "${credentials_file}" ]]; then
    if grep -q "\\[${profile_name}\\]" "${credentials_file}"; then
      echo "[SUCCESS] Found AWS credentials file with DigitalOcean Spaces profile."
      return 0
    else
      echo "[WARNING] AWS credentials file found, but does not have DigitalOcean Spaces profile."
    fi
  else
    echo "[WARNING] AWS credentials file not found: ${credentials_file}"
  fi

  return 1
}

# terraform_plan_show_apply PLAN_FILE
# Creates a plan, shows it, and prompts to apply
terraform_plan_show_apply() {
  local plan_file="$1"

  echo "[INFO] Terraform plan"
  terraform plan -out "${plan_file}" >/dev/null

  echo "[INFO] Terraform showing plan preview."
  terraform show "${plan_file}" || true

  read -r -p "Proceed with apply using this plan? [y/N] " CONFIRM
  case "${CONFIRM}" in
    y|Y|yes|YES)
      terraform apply "${plan_file}"
      ;;
    *)
      echo "[INFO] Aborting by user choice."
      exit 0
      ;;
  esac
}


