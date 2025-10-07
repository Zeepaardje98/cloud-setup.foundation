# Shared backend configuration for DigitalOcean Spaces (S3-compatible)

endpoints = {
	s3 = "https://ams3.digitaloceanspaces.com"
}

bucket  = "organization-infrastructure.terraform-state-bucket"
region  = "us-east-1"

# AWS-specific checks disabled for Spaces
skip_credentials_validation = true
skip_requesting_account_id  = true
skip_metadata_api_check     = true
skip_region_validation      = true
skip_s3_checksum            = true

# Enable lockfile-based state locking in Spaces (Terraform >= 1.11)
use_lockfile = true
