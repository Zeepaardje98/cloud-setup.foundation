#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT_DIR}"

# Paths
# Helper script for common functions
COMMON_SH="${ROOT_DIR}/../../scripts/common.sh"

# Shared backend.hcl lives two levels up at deployment/terraform/backend.hcl
SHARED_BACKEND_HCL="${ROOT_DIR}/../backend.hcl"

# State key for this stack (unique per deployment)
STATE_KEY="foundation/02-github-organization/terraform.tfstate"

# AWS credentials file for DigitalOcean Spaces backend
AWS_CREDENTIALS_FILE="${ROOT_DIR}/../../.aws/credentials"
AWS_PROFILE="digitalocean-spaces"

# Load common helpers
if [[ -f "${COMMON_SH}" ]]; then
  # shellcheck disable=SC1090
  source "${COMMON_SH}"
else
  echo "[ERROR] Common helper not found: ${COMMON_SH}"
  exit 1
fi

if check_aws_credentials "${AWS_CREDENTIALS_FILE}" "${AWS_PROFILE}"; then
  echo "[INFO] Terraform init attempt with remote state (uses backend)"

  # Validate shared backend file exists
  if [[ ! -f "${SHARED_BACKEND_HCL}" ]]; then
    echo "[ERROR] Backend file not found: ${SHARED_BACKEND_HCL}"
    exit 1
  fi

  # Export Spaces credentials location for Terraform backend
  export AWS_PROFILE
  export AWS_SHARED_CREDENTIALS_FILE="${AWS_CREDENTIALS_FILE}"

  if ! terraform init -backend-config="${SHARED_BACKEND_HCL}" -backend-config="key=${STATE_KEY}"; then
      echo "[WARNING] Terraform init with remote state failed, exiting."
      exit 1
  else
      echo "[INFO] Terraform init with remote state successful."
  fi
fi

terraform_plan_show_apply ".tfplan.local"

