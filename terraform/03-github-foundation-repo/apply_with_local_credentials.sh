#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT_DIR}"

AWS_CREDENTIALS_FILE="${ROOT_DIR}/../.aws/credentials"
AWS_PROFILE="digitalocean-spaces"

if ! command -v awk >/dev/null 2>&1; then
  echo "[ERROR] awk is required"
  exit 1
fi

if [[ ! -f "${AWS_CREDENTIALS_FILE}" ]]; then
  echo "[ERROR] Credentials file not found: ${AWS_CREDENTIALS_FILE}"
  exit 1
fi

AWS_ACCESS_KEY_ID=$(awk -v p="${AWS_PROFILE}" 'BEGIN{f=0} $0=="["p"]"{f=1;next} f&&/^aws_access_key_id/{print $3; exit}' "${AWS_CREDENTIALS_FILE}" || true)
AWS_SECRET_ACCESS_KEY=$(awk -v p="${AWS_PROFILE}" 'BEGIN{f=0} $0=="["p"]"{f=1;next} f&&/^aws_secret_access_key/{print $3; exit}' "${AWS_CREDENTIALS_FILE}" || true)

if [[ -z "${AWS_ACCESS_KEY_ID}" || -z "${AWS_SECRET_ACCESS_KEY}" ]]; then
  echo "[ERROR] Could not read AWS keys for profile ${AWS_PROFILE} from ${AWS_CREDENTIALS_FILE}"
  exit 1
fi

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

exec ./apply.sh


