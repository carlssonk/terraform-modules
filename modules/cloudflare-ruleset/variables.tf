variable "enabled" {
  description = "Whether to create the ruleset"
  type        = bool
  default     = true
}

variable "account_id" {
  description = "The Cloudflare Account ID (optional, use either account_id or zone_id)"
  type        = string
  default     = null
}

variable "zone_id" {
  description = "The Cloudflare Zone ID (optional, use either account_id or zone_id)"
  type        = string
  default     = null
}

variable "name" {
  description = "The human-readable name of the ruleset"
  type        = string
}

variable "description" {
  description = "An informative description of the ruleset"
  type        = string
  default     = ""
}

variable "kind" {
  description = "The kind of the ruleset. Available values: 'managed', 'custom', 'root', 'zone'"
  type        = string

  validation {
    condition     = contains(["managed", "custom", "root", "zone"], var.kind)
    error_message = "Kind must be one of: managed, custom, root, zone."
  }
}

variable "phase" {
  description = "The phase of the ruleset"
  type        = string

  validation {
    condition = contains([
      "ddos_l4",
      "ddos_l7",
      "http_config_settings",
      "http_custom_errors",
      "http_log_custom_fields",
      "http_ratelimit",
      "http_request_cache_settings",
      "http_request_dynamic_redirect",
      "http_request_firewall_custom",
      "http_request_firewall_managed",
      "http_request_late_transform",
      "http_request_origin",
      "http_request_redirect",
      "http_request_sanitize",
      "http_request_sbfm",
      "http_request_transform",
      "http_response_compression",
      "http_response_firewall_managed",
      "http_response_headers_transform",
      "magic_transit",
      "magic_transit_ids_managed",
      "magic_transit_managed",
      "magic_transit_ratelimit"
    ], var.phase)
    error_message = "Phase must be a valid Cloudflare ruleset phase."
  }
}

variable "rules" {
  description = "The list of rules in the ruleset. See Cloudflare documentation for the full schema of action_parameters and other nested attributes."
  type        = any
  default     = []

  validation {
    condition     = can([for rule in var.rules : rule.action])
    error_message = "Each rule must have an 'action' attribute."
  }

  validation {
    condition     = can([for rule in var.rules : rule.expression])
    error_message = "Each rule must have an 'expression' attribute."
  }
}

