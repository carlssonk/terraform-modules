# ============================================================================
# SIMPLIFIED ZONE SETTINGS MODULE
# ============================================================================
# Manages Cloudflare zone settings for a single zone.
# Use one instance of this module per zone you want to configure.
# ============================================================================

data "cloudflare_zones" "this" {
  name = var.zone_name
}

locals {
  zone_id = data.cloudflare_zones.this.result[0].id

  # Default settings with sensible security and performance values
  default_settings = {
    # SSL/TLS
    ssl                      = "full"
    always_use_https         = "on"
    min_tls_version          = "1.2"
    automatic_https_rewrites = "on"
    tls_1_3                  = "on"

    # Security
    security_level = "medium"
    browser_check  = "on"
    challenge_ttl  = 1800
    privacy_pass   = "on"

    # Performance
    brotli      = "on"
    early_hints = "off"
    http2       = "on"
    http3       = "on"
    "0rtt"      = "on"

    # Caching
    browser_cache_ttl = 14400

    # Network
    ipv6                     = "on"
    websockets               = "on"
    opportunistic_encryption = "on"
    opportunistic_onion      = "on"

    # Other
    development_mode = "off"
    rocket_loader    = "off"
  }

  # Merge user settings with defaults
  final_settings = merge(local.default_settings, var.settings)
}

resource "cloudflare_zone_setting" "this" {
  for_each = local.final_settings

  zone_id    = local.zone_id
  setting_id = each.key
  value      = each.value
}


