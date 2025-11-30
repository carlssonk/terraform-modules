output "zone_id" {
  description = "The Cloudflare zone ID"
  value       = data.cloudflare_zone.domain.id
}

output "zone_name" {
  description = "The Cloudflare zone name"
  value       = data.cloudflare_zone.domain.name
}

output "dns_records" {
  description = "Map of DNS record names to their details"
  value = {
    for key, record in cloudflare_record.this :
    key => {
      id       = record.id
      hostname = record.hostname
      name     = record.name
      type     = record.type
      value    = record.value
      ttl      = record.ttl
      proxied  = record.proxied
    }
  }
}

output "dns_record_ids" {
  description = "Map of DNS record keys to their Cloudflare IDs"
  value = {
    for key, record in cloudflare_record.this :
    key => record.id
  }
}

output "dns_record_hostnames" {
  description = "Map of DNS record keys to their full hostnames"
  value = {
    for key, record in cloudflare_record.this :
    key => record.hostname
  }
}

