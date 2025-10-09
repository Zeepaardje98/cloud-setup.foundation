# Cloud Setup Foundation

This repository bootstraps the foundational cloud resources for an organization so future projects can deploy reliably. It provisions:

- S3-compatible bucket in DigitalOcean Spaces for Terraform remote state
- GitHub organization configuration for CI and secrets
- A GitHub repository to host this very code, wired for re-runs via CI

## Prerequisites

- Bash shell (Linux/macOS, or Windows via WSL/Git Bash)
- Terraform ~> 1.11
- DigitalOcean account and API token (personal access token)
- GitHub organization and a fine‑grained personal access token
  - Organization permissions: Actions = Read and write (for org secrets/variables)
  - Set provider `owner` or export `GITHUB_OWNER`

## Repository Layout

- `terraform/01-digitalocean-remote-state/` — creates the Spaces bucket and access keys for Terraform remote state
- `terraform/02-github-organization/` — configures org‑level GitHub Actions secrets/variables for remote state
- `terraform/03-github-foundation-repo/` — creates a repository for this codebase and seeds CI variables
- `terraform/backend.hcl` — shared backend configuration for DigitalOcean Spaces (S3 compatible)

## Getting started
Step 1 - 3 are first ran locally and require variables from their respective terraform.tfvars.

### Step 1: Create remote state in DigitalOcean
This step creates the AWS-compatible Spaces bucket and two keys for accessing this bucket. One of the keys is automatically added as plaintext in `terraform/.aws/credentials`, since the next steps require this key.
- Use local `.tfvars` (copy from `terraform/01-digitalocean-remote-state/terraform.tfvars.example`)
- Requires a DigitalOcean API token (see `terraform/01-digitalocean-remote-state/terraform.tfvars.example`).

```
cd ./terraform
./01-digitalocean-remote-state/01_apply_local-credentials-and-state.sh
```
After apply, the script migrates state to the Spaces backend and securely removes local state artifacts.

Optional re-apply later (now using remote state):
```
./01-digitalocean-remote-state/02_apply_local-credentials.sh
```
Use this only if you need to make further changes to the remote‑state stack before proceeding.

### Step 2: Configure GitHub organization secrets/variables
This step configures your GitHub organization to hold the remote state access keys as org‑level secrets/variables used by CI runners.
- Use local `.tfvars` (copy from `terraform/02-github-organization/terraform.tfvars.example`)
- Requires a GitHub token (see `terraform/02-github-organization/terraform.tfvars.example`)

```
./02-github-organization/01_apply_local-credentials.sh
```

### Step 3: Create the foundation repository in GitHub
This step creates a repository for this codebase and configures the variables needed for CI re‑runs of this and prior steps.
- Use local `.tfvars` (copy from `terraform/03-github-foundation-repo/terraform.tfvars.example`)
- Requires a GitHub token (see `terraform/03-github-foundation-repo/terraform.tfvars.example`).

```
./03-github-foundation-repo/01_apply_with_local_credentials.sh
```

### CI Re‑runs

Each directory includes an `apply.sh` that can be executed by GitHub Actions. The local wrapper scripts (`01_*` / `02_*`) simply export credentials and call the corresponding `./apply.sh`. With the workflows in `.github/`, CI can re‑run the same deployments using the org secrets/variables configured in Step 2.

### Notes

- Remote state backend settings are in `terraform/backend.hcl` and are shared by stacks.
- Scripts securely clean up local state files after successful migration to remote state. If `shred` is not available, cleanup is skipped with a warning.


