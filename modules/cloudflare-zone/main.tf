# ============================================================================
# ZONE-SCOPED MODULE
# ============================================================================
# This module manages zone-level Cloudflare resources that can only be 
# declared ONCE per zone. Do NOT instantiate this module per environment.
# ============================================================================

locals {
  apps_grouped_by_root_domain = {
    for root_domain in distinct(values(var.apps)[*].root_domain) :
    root_domain => [
      for app_config in var.apps : app_config
      if app_config.root_domain == root_domain
    ]
  }

  ruleset_rules = {
    for root_domain, apps in local.apps_grouped_by_root_domain : root_domain => flatten([
      for app in apps :
      can(app.cloudflare.ssl_mode) ? [{
        action = "set_config"
        action_parameters = {
          ssl = app.cloudflare.ssl_mode
        }
        expression = app.subdomain == "www" ? (
          format(
            "(%s%s)",
            format("http.host eq \"%s\" or http.host eq \"%s.%s\"", app.root_domain, app.subdomain, app.root_domain),
            length([for env in var.environments : env if env != "production"]) > 0 ?
            format(" or %s", join(" or ", [for env in var.environments :
              format("http.host eq \"%s.%s\"", env, app.root_domain)
              if env != "production"
            ])) : ""
          )
          ) : join(" or ", [for env in var.environments :
            env == "production" ?
            format("http.host eq \"%s.%s\"", app.subdomain, app.root_domain) :
            format("http.host eq \"%s-%s.%s\"", app.subdomain, env, app.root_domain)
        ])
        description = "Cloudflare rules for ${app.subdomain}.${app.root_domain}"
      }] : []
    ])
  }
}

data "cloudflare_zones" "domain" {
  for_each = local.apps_grouped_by_root_domain
  
  name = each.key
}

locals {
  zone_ids = {
    for domain in keys(local.apps_grouped_by_root_domain) :
    domain => data.cloudflare_zones.domain[domain].result[0].id
  }
}

# ZONE-SCOPED: Individual zone settings
# Settings apply globally to all subdomains and environments
locals {
  # Flatten zone settings into individual resources
  zone_settings_map = merge([
    for domain in keys(local.apps_grouped_by_root_domain) : {
      # SSL/TLS
      "${domain}_ssl"                      = { zone_id = local.zone_ids[domain], setting_id = "ssl", value = lookup(var.zone_settings, "ssl", "full") }
      "${domain}_always_use_https"         = { zone_id = local.zone_ids[domain], setting_id = "always_use_https", value = lookup(var.zone_settings, "always_use_https", "on") }
      "${domain}_min_tls_version"          = { zone_id = local.zone_ids[domain], setting_id = "min_tls_version", value = lookup(var.zone_settings, "min_tls_version", "1.2") }
      "${domain}_automatic_https_rewrites" = { zone_id = local.zone_ids[domain], setting_id = "automatic_https_rewrites", value = lookup(var.zone_settings, "automatic_https_rewrites", "on") }
      "${domain}_tls_1_3"                  = { zone_id = local.zone_ids[domain], setting_id = "tls_1_3", value = lookup(var.zone_settings, "tls_1_3", "on") }

      # Security
      "${domain}_security_level"           = { zone_id = local.zone_ids[domain], setting_id = "security_level", value = lookup(var.zone_settings, "security_level", "medium") }
      "${domain}_browser_check"            = { zone_id = local.zone_ids[domain], setting_id = "browser_check", value = lookup(var.zone_settings, "browser_check", "on") }
      "${domain}_challenge_ttl"            = { zone_id = local.zone_ids[domain], setting_id = "challenge_ttl", value = lookup(var.zone_settings, "challenge_ttl", 1800) }
      "${domain}_privacy_pass"             = { zone_id = local.zone_ids[domain], setting_id = "privacy_pass", value = lookup(var.zone_settings, "privacy_pass", "on") }

      # Performance
      "${domain}_brotli"                   = { zone_id = local.zone_ids[domain], setting_id = "brotli", value = lookup(var.zone_settings, "brotli", "on") }
      "${domain}_early_hints"              = { zone_id = local.zone_ids[domain], setting_id = "early_hints", value = lookup(var.zone_settings, "early_hints", "off") }
      "${domain}_http2"                    = { zone_id = local.zone_ids[domain], setting_id = "http2", value = lookup(var.zone_settings, "http2", "on") }
      "${domain}_http3"                    = { zone_id = local.zone_ids[domain], setting_id = "http3", value = lookup(var.zone_settings, "http3", "on") }
      "${domain}_zero_rtt"                 = { zone_id = local.zone_ids[domain], setting_id = "0rtt", value = lookup(var.zone_settings, "zero_rtt", "on") }

      # Caching
      "${domain}_browser_cache_ttl"        = { zone_id = local.zone_ids[domain], setting_id = "browser_cache_ttl", value = lookup(var.zone_settings, "browser_cache_ttl", 14400) }
      
      # Network
      "${domain}_ipv6"                     = { zone_id = local.zone_ids[domain], setting_id = "ipv6", value = lookup(var.zone_settings, "ipv6", "on") }
      "${domain}_websockets"               = { zone_id = local.zone_ids[domain], setting_id = "websockets", value = lookup(var.zone_settings, "websockets", "on") }
      "${domain}_opportunistic_encryption" = { zone_id = local.zone_ids[domain], setting_id = "opportunistic_encryption", value = lookup(var.zone_settings, "opportunistic_encryption", "on") }
      "${domain}_opportunistic_onion"      = { zone_id = local.zone_ids[domain], setting_id = "opportunistic_onion", value = lookup(var.zone_settings, "opportunistic_onion", "on") }

      # Other
      "${domain}_development_mode"         = { zone_id = local.zone_ids[domain], setting_id = "development_mode", value = lookup(var.zone_settings, "development_mode", "off") }
      "${domain}_rocket_loader"            = { zone_id = local.zone_ids[domain], setting_id = "rocket_loader", value = lookup(var.zone_settings, "rocket_loader", "off") }
    }
  ]...)
}

resource "cloudflare_zone_setting" "this" {
  for_each = local.zone_settings_map

  zone_id    = each.value.zone_id
  setting_id = each.value.setting_id
  value      = each.value.value
}

# ZONE-SCOPED: Only one ruleset per zone per phase
# Rules target specific environments via host expressions
resource "cloudflare_ruleset" "this" {
  for_each = var.create_rulesets ? { for k, v in local.apps_grouped_by_root_domain : k => v if length(local.ruleset_rules[k]) > 0 } : {}
  
  zone_id     = local.zone_ids[each.key]
  name        = "Dynamic Main Ruleset"
  description = "Dynamic ruleset for managing app settings"
  kind        = "zone"
  phase       = "http_config_settings"

  rules = [
    for rule in local.ruleset_rules[each.key] : {
      action      = rule.action
      expression  = rule.expression
      description = lookup(rule, "description", null)
      action_parameters = {
        ssl = lookup(lookup(rule, "action_parameters", {}), "ssl", null)
      }
    }
  ]
}


