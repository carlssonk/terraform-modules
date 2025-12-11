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

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "path_to_index_document" {
  description = "Path prefix to add to all requests (e.g., '/latest', '/v1'). Set to empty string or '/' to disable path rewriting."
  type        = string
  default     = ""

  validation {
    condition     = var.path_to_index_document == "" || can(regex("^/[a-zA-Z0-9._-]*$", var.path_to_index_document))
    error_message = "path_to_index_document must be empty or start with '/' followed by valid path characters."
  }
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}