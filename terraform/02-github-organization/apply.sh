#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT_DIR}"

# Shared backend.hcl lives two levels up at deployment/terraform/backend.hcl
SHARED_BACKEND_HCL="${ROOT_DIR}/../backend.hcl"
# State key for this stack
STATE_KEY="foundation/02-github-organisation/terraform.tfstate"

# Load common helpers
COMMON_SH="${ROOT_DIR}/../../scripts/common.sh"
if [[ -f "${COMMON_SH}" ]]; then
  source "${COMMON_SH}"
else
  echo "[ERROR] Common helper not found: ${COMMON_SH}"
  exit 1
fi

# Standard init/plan/show/apply
terraform_deploy "${SHARED_BACKEND_HCL}" "${STATE_KEY}"
