#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT_DIR}"

# Load helpers
COMMON_SH="${ROOT_DIR}/../../scripts/common.sh"
if [[ -f "${COMMON_SH}" ]]; then
  # shellcheck disable=SC1090
  source "${COMMON_SH}"
else
  echo "[ERROR] Helper not found at path: ${COMMON_SH}"
  exit 1
fi

# Backend file that can be toggled for local vs remote state
BACKEND_FILE="backend.tf"

# Ensure backend file is disabled
if [[ -f ${BACKEND_FILE} ]]; then mv "${BACKEND_FILE}" "${BACKEND_FILE}.disabled"; fi

# Standard init/plan/show/apply
# Initialize passing shared backend config and a unique key for this stack
if ! terraform init -reconfigure; then
    echo "[WARNING] Terraform init with local state failed."
    exit 1
else
    echo "[INFO] Terraform init with local state successful."
fi

echo "[INFO] Terraform plan"
terraform plan -out ".tfplan.local" >/dev/null

echo "[INFO] Terraform showing plan preview."
terraform show ".tfplan.local" || true

read -r -p "Proceed with apply using this plan? [y/N] " CONFIRM
case "${CONFIRM}" in
    y|Y|yes|YES)
        terraform apply ".tfplan.local"
    ;;
    *)
        echo "[INFO] Aborting by user choice."
        exit 0
    ;;
esac

# Update local AWS credentials after the new deployment
ACCESS_KEY_LOCAL=$(terraform output -raw bucket_spaces_access_key_local 2>/dev/null || echo "")
SECRET_KEY_LOCAL=$(terraform output -raw bucket_spaces_secret_key_local 2>/dev/null || echo "")
if [[ -n "${ACCESS_KEY_LOCAL}" && -n "${SECRET_KEY_LOCAL}" ]]; then
  update_local_aws_credentials "${ROOT_DIR}/../.aws/credentials" "digitalocean-spaces" "${ACCESS_KEY_LOCAL}" "${SECRET_KEY_LOCAL}"
else
  echo "[WARNING] Could not extract remote state bucket Spaces credentials for local usage from Terraform outputs." >&2
fi