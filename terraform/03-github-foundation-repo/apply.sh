#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT_DIR}"

# Paths
COMMON_SH="${ROOT_DIR}/../../scripts/common.sh"
SHARED_BACKEND_HCL="${ROOT_DIR}/../backend.hcl"

# State key for this stack
STATE_KEY="foundation/03-github-foundation-repo/terraform.tfstate"

# AWS credentials file for DigitalOcean Spaces backend
AWS_CREDENTIALS_FILE="${ROOT_DIR}/../.aws/credentials"
AWS_PROFILE="digitalocean-spaces"

if [[ -f "${COMMON_SH}" ]]; then
  # shellcheck disable=SC1090
  source "${COMMON_SH}"
else
  echo "[ERROR] Common helper not found: ${COMMON_SH}"
  exit 1
fi

if check_aws_credentials "${AWS_CREDENTIALS_FILE}" "${AWS_PROFILE}"; then
  echo "[INFO] Terraform init with remote state"

  if [[ ! -f "${SHARED_BACKEND_HCL}" ]]; then
    echo "[ERROR] Backend file not found: ${SHARED_BACKEND_HCL}"
    exit 1
  fi

  export AWS_PROFILE
  export AWS_SHARED_CREDENTIALS_FILE="${AWS_CREDENTIALS_FILE}"

  if ! terraform init -backend-config="${SHARED_BACKEND_HCL}" -backend-config="key=${STATE_KEY}"; then
    echo "[WARNING] Terraform init failed"
    exit 1
  fi
fi

terraform_plan_show_apply ".tfplan.local"


