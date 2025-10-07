variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc1"
}

variable "droplet_size" {
  description = "Droplet size for Vault"
  type        = string
  default     = "s-1vcpu-2gb"
}

variable "image" {
  description = "Droplet base image slug"
  type        = string
  default     = "ubuntu-24-04-x64"
}

variable "create_ssh_key" {
  description = "Whether to create an SSH key in DO from provided public key"
  type        = bool
  default     = true
}

variable "ssh_public_key" {
  description = "Public key content used when create_ssh_key is true"
  type        = string
  default     = ""
}

variable "existing_ssh_key_ids" {
  description = "Existing DO SSH key IDs to authorize"
  type        = list(string)
  default     = []
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vault_api_port" {
  description = "Vault API port"
  type        = string
  default     = "8200"
}

variable "vault_allowed_cidrs" {
  description = "CIDR blocks allowed to access Vault API"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cloud_init" {
  description = "Cloud-init user data to install/configure Vault. Do not embed secrets."
  type        = string
  default     = ""
}

