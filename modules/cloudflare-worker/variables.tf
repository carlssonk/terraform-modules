variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "zone_name" {
  description = "The zone name (domain) to attach the worker to"
  type        = string
}

variable "worker_name" {
  description = "Name of the Cloudflare Worker"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9_-]+$", var.worker_name))
    error_message = "Worker name must contain only lowercase letters, numbers, underscores, and hyphens."
  }
}

variable "worker_script" {
  description = "The JavaScript content of the Worker script"
  type        = string
}

variable "compatibility_date" {
  description = "Date indicating targeted support in the Workers runtime. Backwards incompatible fixes to the runtime following this date will not affect this Worker."
  type        = string
  default     = "2024-01-01"

  validation {
    condition     = can(regex("^\\d{4}-\\d{2}-\\d{2}$", var.compatibility_date))
    error_message = "Compatibility date must be in YYYY-MM-DD format."
  }
}

variable "compatibility_flags" {
  description = "Flags that enable or disable certain features in the Workers runtime."
  type        = list(string)
  default     = []
}

variable "logpush" {
  description = "Whether Logpush is turned on for the Worker"
  type        = bool
  default     = false
}

variable "routes" {
  description = "Map of routes to attach the worker to. Each route has a pattern."
  type = map(object({
    pattern = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for route in var.routes : can(regex("^[^\\s]+$", route.pattern))
    ])
    error_message = "Route patterns must not contain whitespace."
  }
}

variable "secrets" {
  description = "Map of secret text bindings (sensitive values like API keys)"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "kv_namespaces" {
  description = "Map of KV namespace bindings. Key is the binding name, value is the namespace ID."
  type        = map(string)
  default     = {}
}

variable "plain_text_bindings" {
  description = "Map of plain text bindings (environment variables)"
  type        = map(string)
  default     = {}
}
