variable "enabled" {
  description = "Whether to create the path prefix ruleset"
  type        = bool
  default     = true
}

variable "zone_id" {
  description = "The Cloudflare Zone ID"
  type        = string
}

variable "path_prefix" {
  description = "The path prefix to add to all requests (e.g., 'latest/', 'v1/', 'docs/'). Should include trailing slash if desired."
  type        = string

  validation {
    condition     = var.path_prefix != ""
    error_message = "path_prefix cannot be empty."
  }

  validation {
    condition     = !can(regex("^/", var.path_prefix))
    error_message = "path_prefix should not start with '/'. Use 'latest/' instead of '/latest/'."
  }
}

variable "expression" {
  description = "Cloudflare expression to match requests. Default matches all requests."
  type        = string
  default     = "true"
}

variable "name" {
  description = "Custom name for the ruleset. If empty, a default name will be generated."
  type        = string
  default     = ""
}

variable "description" {
  description = "Custom description for the ruleset. If empty, a default description will be generated."
  type        = string
  default     = ""
}

variable "rule_description" {
  description = "Custom description for the rule. If empty, a default description will be generated."
  type        = string
  default     = ""
}

