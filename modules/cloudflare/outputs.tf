output "zone_ids" {
  description = "Map of root domains to their Cloudflare zone IDs"
  value = {
    for domain, zone in data.cloudflare_zone.domain :
    domain => zone.id
  }
}

output "zone_names" {
  description = "Map of root domains to their zone names"
  value = {
    for domain, zone in data.cloudflare_zone.domain :
    domain => zone.name
  }
}

output "zone_settings" {
  description = "Map of root domains to their zone settings override IDs"
  value = {
    for domain, settings in cloudflare_zone_settings_override.this :
    domain => settings.id
  }
}

output "rulesets" {
  description = "Map of root domains to their ruleset IDs"
  value = {
    for domain, ruleset in cloudflare_ruleset.this :
    domain => ruleset.id
  }
}

output "apps_by_domain" {
  description = "Map of root domains to their associated apps"
  value       = local.apps_grouped_by_root_domain
}

