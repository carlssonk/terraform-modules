output "ruleset_id" {
  description = "The unique ID of the created ruleset"
  value       = module.path_prefix_ruleset.id
}

output "ruleset_version" {
  description = "The version of the ruleset"
  value       = module.path_prefix_ruleset.version
}

output "ruleset" {
  description = "The complete ruleset object"
  value       = module.path_prefix_ruleset.ruleset
}

