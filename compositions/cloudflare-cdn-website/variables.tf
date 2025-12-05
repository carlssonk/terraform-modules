variable "root_domain" {
  description = "The root domain name (e.g., example.com)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)*$", var.root_domain))
    error_message = "Root domain must be a valid domain name."
  }
}

variable "subdomain" {
  description = "The subdomain to create (e.g., 'www', 'blog', 'docs'). If set to 'www', will also create a root domain redirect."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.subdomain))
    error_message = "Subdomain must contain only lowercase letters, numbers, and hyphens, and must start and end with a letter or number."
  }
}

variable "index_document" {
  description = "The index document for the website (default: index.html)"
  type        = string
  default     = "index.html"
}

variable "force_destroy" {
  description = "Allow destruction of non-empty S3 buckets. WARNING: Setting this to true will delete all objects when the bucket is destroyed."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

# Cloudflare Worker variables
variable "enable_worker" {
  description = "Enable Cloudflare Worker for feature-flag based routing"
  type        = bool
  default     = false
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID (required if enable_worker is true)"
  type        = string
  default     = null
}

variable "worker_name" {
  description = "Name of the Cloudflare Worker (defaults to domain-based name)"
  type        = string
  default     = null
}

variable "worker_script" {
  description = "Custom worker script content (defaults to the bundled worker.js)"
  type        = string
  default     = null
}

variable "worker_compatibility_date" {
  description = "Compatibility date for the worker runtime (YYYY-MM-DD format)"
  type        = string
  default     = "2024-01-01"
}

variable "worker_compatibility_flags" {
  description = "Compatibility flags for the worker runtime"
  type        = list(string)
  default     = []
}

variable "worker_logpush" {
  description = "Enable Logpush for the worker"
  type        = bool
  default     = false
}

variable "worker_secrets" {
  description = "Secret bindings for the worker (e.g., CONFIGCAT_API_KEY)"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "worker_plain_text_bindings" {
  description = "Plain text bindings for the worker (environment variables)"
  type        = map(string)
  default     = {}
}

variable "worker_kv_namespaces" {
  description = "KV namespace bindings for the worker"
  type        = map(string)
  default     = {}
}