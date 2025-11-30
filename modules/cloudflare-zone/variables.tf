variable "zone_name" {
  description = "The Cloudflare zone name (domain) to manage settings for"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)*$", var.zone_name))
    error_message = "Zone name must be a valid domain name."
  }
}

variable "settings" {
  description = "Cloudflare zone settings to configure. Only specify settings you want to override from defaults."
  type        = map(any)
  default     = {}

  # Available settings (showing defaults):
  # ssl                      = "full"        # off, flexible, full, strict
  # always_use_https         = "on"          # on, off
  # min_tls_version          = "1.2"         # 1.0, 1.1, 1.2, 1.3
  # automatic_https_rewrites = "on"          # on, off
  # tls_1_3                  = "on"          # on, off, zrt (zero round trip)
  # security_level           = "medium"      # off, essentially_off, low, medium, high, under_attack
  # browser_check            = "on"          # on, off
  # challenge_ttl            = 1800          # 300-31536000 seconds
  # privacy_pass             = "on"          # on, off
  # brotli                   = "on"          # on, off
  # early_hints              = "off"         # on, off
  # http2                    = "on"          # on, off
  # http3                    = "on"          # on, off
  # "0rtt"                   = "on"          # on, off (note: use "0rtt" as key)
  # browser_cache_ttl        = 14400         # seconds (0, 30, 60, 120, 300, 1200, 1800, 3600, 7200, 10800, 14400, 18000, 28800, 43200, 57600, 72000, 86400, 172800, 259200, 345600, 432000, 691200, 1382400, 2073600, 2678400, 5356800, 16070400, 31536000)
  # ipv6                     = "on"          # on, off
  # websockets               = "on"          # on, off
  # opportunistic_encryption = "on"          # on, off
  # opportunistic_onion      = "on"          # on, off
  # development_mode         = "off"         # on, off
  # rocket_loader            = "off"         # on, off, manual
}

