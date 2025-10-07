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
STATE_KEY="foundation/01-digitalocean-remote-state/terraform.tfstate"

# Load helpers
if [[ -f "${COMMON_SH}" ]]; then
  # shellcheck disable=SC1090
  source "${COMMON_SH}"
else
  echo "[ERROR] Helper not found at path: ${COMMON_SH}"
  exit 1
fi

# Ensure backend file is present (restore if previously disabled)
BACKEND_FILE="backend.tf"
if [[ -f ${BACKEND_FILE}.disabled ]]; then mv "${BACKEND_FILE}.disabled" "${BACKEND_FILE}"; fi

# Standard init/plan/show/apply
terraform_deploy "${SHARED_BACKEND_HCL}" "${STATE_KEY}"
