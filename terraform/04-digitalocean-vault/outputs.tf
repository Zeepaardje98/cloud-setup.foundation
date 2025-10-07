output "vault_droplet_id" {
  description = "ID of the Vault droplet"
  value       = digitalocean_droplet.vault.id
}

output "vault_droplet_ip" {
  description = "Public IPv4 of the Vault droplet"
  value       = digitalocean_droplet.vault.ipv4_address
}

output "vault_firewall_id" {
  description = "ID of the firewall protecting Vault"
  value       = digitalocean_firewall.vault.id
}

