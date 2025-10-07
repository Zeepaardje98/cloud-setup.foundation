#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT_DIR}"

# Paths
# Helper script for common functions
COMMON_SH="${ROOT_DIR}/../../scripts/common.sh"

# Shared backend.hcl lives two levels up at deployment/terraform/backend.hcl
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

if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
  echo "[ERROR] Missing AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY in environment."
  echo "[HINT] Run apply_with_local_credentials.sh for local usage, or provide CI secrets."
  exit 1
fi

if [[ ! -f "${SHARED_BACKEND_HCL}" ]]; then
  echo "[ERROR] Backend file not found: ${SHARED_BACKEND_HCL}"
  exit 1
fi

if [[ -n "${AWS_SESSION_TOKEN:-}" ]]; then export AWS_SESSION_TOKEN; fi

if ! terraform init -backend-config="${SHARED_BACKEND_HCL}" -backend-config="key=${STATE_KEY}"; then
  echo "[WARNING] Terraform init failed"
  exit 1
fi

terraform_plan_show_apply ".tfplan.local"


