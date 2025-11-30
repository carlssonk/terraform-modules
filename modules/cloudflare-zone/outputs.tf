output "zone_ids" {
  description = "Map of root domains to their Cloudflare zone IDs"
  value       = local.zone_ids
}

output "zone_names" {
  description = "Map of root domains to their zone names"
  value = {
    for domain in keys(local.apps_grouped_by_root_domain) :
    domain => data.cloudflare_zones.domain[domain].result[0].name
  }
}

output "zone_settings" {
  description = "Map of zone settings keys to their IDs"
  value = {
    for key, setting in cloudflare_zone_setting.this :
    key => setting.id
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

