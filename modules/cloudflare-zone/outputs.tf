output "zone_id" {
  description = "The Cloudflare zone ID"
  value       = local.zone_id
}

output "zone_name" {
  description = "The Cloudflare zone name"
  value       = data.cloudflare_zones.this.result[0].name
}

output "settings" {
  description = "Map of configured zone settings"
  value = {
    for key, setting in cloudflare_zone_setting.this :
    key => {
      id    = setting.id
      value = setting.value
    }
  }
}

