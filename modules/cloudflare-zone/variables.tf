variable "apps" {
  description = "Map of application configurations. Each app should have: app_name, root_domain, subdomain, and cloudflare settings."
  type        = any
  # type = map(object({
  #   app_name    = string
  #   root_domain = string
  #   subdomain   = string
  #   cloudflare = object({
  #     ssl_mode = optional(string) # off, flexible, full, strict
  #   })
  # }))
}

variable "environments" {
  description = "List of environments (e.g., ['production', 'dev', 'staging']). 'production' is treated specially for subdomain naming."
  type        = list(string)
  default     = ["production"]

  validation {
    condition     = contains(var.environments, "production")
    error_message = "Environments list must include 'production'."
  }
}

variable "create_rulesets" {
  description = "Whether to create Cloudflare rulesets. Set to false if another module is managing rulesets for these zones."
  type        = bool
  default     = true
}

variable "zone_settings" {
  description = "Cloudflare zone-level settings to override defaults"
  type        = map(string)
  default     = {}
  # Available settings with defaults shown:
  # ssl = "full"                         # off, flexible, full, strict
  # always_use_https = "on"
  # min_tls_version = "1.2"
  # automatic_https_rewrites = "on"
  # tls_1_3 = "on"
  # security_level = "medium"            # off, essentially_off, low, medium, high, under_attack
  # browser_check = "on"
  # challenge_ttl = "1800"
  # privacy_pass = "on"
  # hsts_enabled = "false"
  # brotli = "on"
  # early_hints = "off"
  # http2 = "on"
  # http3 = "on"
  # zero_rtt = "on"
  # minify_css = "on"
  # minify_js = "on"
  # minify_html = "on"
  # browser_cache_ttl = "14400"
  # ipv6 = "on"
  # websockets = "on"
  # opportunistic_encryption = "on"
  # opportunistic_onion = "on"
  # development_mode = "off"
  # rocket_loader = "off"
}

