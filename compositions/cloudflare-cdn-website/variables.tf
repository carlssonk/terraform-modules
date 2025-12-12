variable "root_domain" {
  description = "The root domain name (e.g., example.com)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)*$", var.root_domain))
    error_message = "Root domain must be a valid domain name."
  }
}

variable "subdomain" {
  description = "The subdomain to create (e.g., 'www', 'blog', 'docs', 'docs.staging'). If set to 'www', will also create a root domain redirect."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9.-]*[a-z0-9])?$", var.subdomain))
    error_message = "Subdomain must contain only lowercase letters, numbers, hyphens, and dots, and must start and end with a letter or number."
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

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the bucket"
  type = list(object({
    id                                 = string
    enabled                            = bool
    prefix                             = optional(string)
    tags                               = optional(map(string), {})
    expiration_days                    = optional(number)
    noncurrent_version_expiration_days = optional(number)
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    noncurrent_version_transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      rule.enabled == true || rule.enabled == false
    ])
    error_message = "Each lifecycle rule must have a valid enabled boolean value."
  }
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
