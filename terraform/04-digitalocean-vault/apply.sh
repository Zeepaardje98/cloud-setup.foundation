#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT_DIR}"

# Paths
COMMON_SH="${ROOT_DIR}/../scripts/common.sh"
SHARED_BACKEND_HCL="${ROOT_DIR}/../../backend.hcl"

# Unique state key for this stack
STATE_KEY="foundation/04-digitalocean-vault/terraform.tfstate"

# AWS credentials file for DigitalOcean Spaces backend(remote terraform state)
AWS_CREDENTIALS_FILE="${ROOT_DIR}/../.aws/credentials"
AWS_PROFILE="digitalocean-spaces"

# Ansible playbook path
REPO_ROOT="$(cd "${ROOT_DIR}/../../../.." && pwd)"
ANSIBLE_PLAYBOOK="${REPO_ROOT}/deployment/ansible/playbooks/vault.yml"

# Load common helpers
if [[ -f "${COMMON_SH}" ]]; then
	# shellcheck disable=SC1090
	source "${COMMON_SH}"
else
	echo "[ERROR] Common helper not found: ${COMMON_SH}"
	exit 1
fi

# Enforce CI-only execution: require CI-provided Spaces credentials
if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
	echo "[ERROR] This stack (04) must run in CI with Secrets. Missing AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY."
	exit 1
fi

echo "[INFO] Using CI-provided Spaces credentials from environment."

if [[ ! -f "${SHARED_BACKEND_HCL}" ]]; then
	echo "[ERROR] Backend file not found: ${SHARED_BACKEND_HCL}"
	exit 1
fi

# Ensure optional session token is passed through if present
if [[ -n "${AWS_SESSION_TOKEN:-}" ]]; then export AWS_SESSION_TOKEN; fi

if ! terraform init -backend-config="${SHARED_BACKEND_HCL}" -backend-config="key=${STATE_KEY}"; then
	echo "[WARNING] Terraform init with remote state failed, exiting."
	exit 1
else
	echo "[INFO] Terraform init with remote state successful."
fi

# Plan, show, and apply with confirmation
terraform_plan_show_apply ".tfplan.local"

# After apply, run Ansible against the droplet to configure Vault
VAULT_IP=$(terraform output -raw vault_droplet_ip)
if [[ -z "${VAULT_IP}" ]]; then
	echo "[ERROR] vault_droplet_ip output is empty"
	exit 1
fi

echo "[INFO] Running Ansible against Vault host: ${VAULT_IP}"
if ! command -v ansible-playbook >/dev/null 2>&1; then
	echo "[ERROR] ansible-playbook not found in PATH"
	exit 1
fi

ANSIBLE_USER=${ANSIBLE_USER:-root}
EXTRA_VARS_ARG=()
if [[ -n "${ANSIBLE_EXTRA_VARS:-}" ]]; then
	EXTRA_VARS_ARG=( -e "${ANSIBLE_EXTRA_VARS}" )
fi

ansible-playbook -i "${VAULT_IP}," -e ansible_user="${ANSIBLE_USER}" "${EXTRA_VARS_ARG[@]}" "${ANSIBLE_PLAYBOOK}"
