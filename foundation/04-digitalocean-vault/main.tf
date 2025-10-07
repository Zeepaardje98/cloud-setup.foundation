terraform {
  required_version = ">= 1.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
  backend "s3" {}
}

provider "digitalocean" {
  token = var.do_token
}

# Get the existing project from the remote state
data "terraform_remote_state" "remote_state" {
  backend = "s3"
  config = {
    endpoints = {
      s3 = "https://ams3.digitaloceanspaces.com"
    }
    bucket                      = "organization-infrastructure.terraform-state-bucket"
    key                         = "foundation/01-digitalocean-remote-state/terraform.tfstate"
    region                      = "us-east-1"
    profile                     = "digitalocean-spaces"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    use_lockfile                = true
  }
}
data "digitalocean_project" "existing" {
  id = data.terraform_remote_state.remote_state.outputs.project_id
}

resource "digitalocean_ssh_key" "vault" {
  count      = var.create_ssh_key ? 1 : 0
  name       = "${lower(replace(data.digitalocean_project.existing.name, " ", "-"))}-vault-key"
  public_key = var.ssh_public_key
}

resource "digitalocean_firewall" "vault" {
  name = "${lower(replace(data.digitalocean_project.existing.name, " ", "-"))}-vault-fw"

  droplet_ids = [digitalocean_droplet.vault.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.ssh_cidr_blocks
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = var.vault_api_port
    source_addresses = var.vault_allowed_cidrs
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

locals {
  ssh_keys_ids = var.create_ssh_key ? [digitalocean_ssh_key.vault[0].id] : []
}

resource "digitalocean_droplet" "vault" {
  name   = "${lower(replace(data.digitalocean_project.existing.name, " ", "-"))}-vault"
  region = var.region
  size   = var.droplet_size
  image  = var.image

  monitoring = true
  backups    = false

  ssh_keys = local.ssh_keys_ids

  user_data = var.cloud_init
}

resource "digitalocean_project_resources" "attach" {
  project   = data.terraform_remote_state.remote_state.outputs.project_id
  resources = [digitalocean_droplet.vault.urn]
}

