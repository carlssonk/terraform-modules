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

  # Conservative default settings that work on all Cloudflare plans
  # Excludes settings that may be read-only or plan-specific (http2, http3, brotli, etc.)
  default_settings = {
    # SSL/TLS - Generally editable on all plans
    ssl                      = "full"
    always_use_https         = "on"
    min_tls_version          = "1.2"
    automatic_https_rewrites = "on"

    # Security - Generally editable on all plans
    security_level = "medium"
    browser_check  = "on"

    # Network - Generally editable on all plans
    ipv6 = "on"

    # Other - Generally editable on all plans
    development_mode = "off"
  }

  # Merge user settings with defaults
  # Users can override defaults or add additional settings via var.settings
  final_settings = merge(local.default_settings, var.settings)
}

resource "cloudflare_zone_setting" "this" {
  for_each = local.final_settings

  zone_id    = local.zone_id
  setting_id = each.key
  value      = each.value
}


