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

data "cloudflare_zone" "domain" {
  for_each = local.apps_grouped_by_root_domain
  name     = each.key
}

# ZONE-SCOPED: Only one settings override per zone
# Settings apply globally to all subdomains and environments
resource "cloudflare_zone_settings_override" "this" {
  for_each = local.apps_grouped_by_root_domain
  zone_id  = data.cloudflare_zone.domain[each.key].id

  settings {
    # SSL/TLS
    ssl                      = lookup(var.zone_settings, "ssl", "full")
    always_use_https         = lookup(var.zone_settings, "always_use_https", "on")
    min_tls_version          = lookup(var.zone_settings, "min_tls_version", "1.2")
    automatic_https_rewrites = lookup(var.zone_settings, "automatic_https_rewrites", "on")
    tls_1_3                  = lookup(var.zone_settings, "tls_1_3", "on")

    # Security
    security_level           = lookup(var.zone_settings, "security_level", "medium")
    browser_check            = lookup(var.zone_settings, "browser_check", "on")
    challenge_ttl            = lookup(var.zone_settings, "challenge_ttl", 1800)
    privacy_pass             = lookup(var.zone_settings, "privacy_pass", "on")


    # Performance
    brotli                   = lookup(var.zone_settings, "brotli", "on")
    early_hints              = lookup(var.zone_settings, "early_hints", "off")
    http2                    = lookup(var.zone_settings, "http2", "on")
    http3                    = lookup(var.zone_settings, "http3", "on")
    zero_rtt                 = lookup(var.zone_settings, "zero_rtt", "on")
    minify {
      css  = lookup(var.zone_settings, "minify_css", "on")
      js   = lookup(var.zone_settings, "minify_js", "on")
      html = lookup(var.zone_settings, "minify_html", "on")
    }

    # Caching
    browser_cache_ttl        = lookup(var.zone_settings, "browser_cache_ttl", 14400)
    
    # Network
    ipv6                     = lookup(var.zone_settings, "ipv6", "on")
    websockets               = lookup(var.zone_settings, "websockets", "on")
    opportunistic_encryption = lookup(var.zone_settings, "opportunistic_encryption", "on")
    opportunistic_onion      = lookup(var.zone_settings, "opportunistic_onion", "on")

    # Other
    development_mode         = lookup(var.zone_settings, "development_mode", "off")
    rocket_loader            = lookup(var.zone_settings, "rocket_loader", "off")
  }
}

# ZONE-SCOPED: Only one ruleset per zone per phase
# Rules target specific environments via host expressions
resource "cloudflare_ruleset" "this" {
  for_each = var.create_rulesets ? { for k, v in local.apps_grouped_by_root_domain : k => v if length(local.ruleset_rules[k]) > 0 } : {}
  
  zone_id     = data.cloudflare_zone.domain[each.key].id
  name        = "Dynamic Main Ruleset"
  description = "Dynamic ruleset for managing app settings"
  kind        = "zone"
  phase       = "http_config_settings"

  rules = jsonencode([
    for rule in local.ruleset_rules[each.key] : {
      action      = rule.action
      expression  = rule.expression
      description = lookup(rule, "description", null)
      action_parameters = {
        ssl = lookup(lookup(rule, "action_parameters", {}), "ssl", null)
      }
    }
  ])
}


