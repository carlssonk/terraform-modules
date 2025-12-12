output "id" {
  description = "The unique ID of the ruleset"
  value       = try(cloudflare_ruleset.this[0].id, null)
}

output "version" {
  description = "The version of the ruleset"
  value       = try(cloudflare_ruleset.this[0].version, null)
}

output "last_updated" {
  description = "The timestamp of when the ruleset was last modified"
  value       = try(cloudflare_ruleset.this[0].last_updated, null)
}

output "ruleset" {
  description = "The complete ruleset object"
  value       = try(cloudflare_ruleset.this[0], null)
}

