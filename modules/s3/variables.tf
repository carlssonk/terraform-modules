variable "bucket_name" {
  description = "Name of the S3 bucket. Must be globally unique."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.bucket_name)) && length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Bucket name must be between 3 and 63 characters, start and end with a lowercase letter or number, and contain only lowercase letters, numbers, hyphens, and periods."
  }
}

variable "force_destroy" {
  description = "Allow destruction of non-empty bucket. WARNING: Setting this to true will delete all objects in the bucket when the bucket is destroyed."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the bucket"
  type        = map(string)
  default     = {}
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm to use. Valid values: AES256, aws:kms"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "SSE algorithm must be either AES256 or aws:kms."
  }
}

variable "kms_master_key_id" {
  description = "AWS KMS master key ID for SSE-KMS encryption. Required if sse_algorithm is aws:kms."
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Enable S3 Bucket Keys for SSE-KMS to reduce encryption costs"
  type        = bool
  default     = true
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

variable "logging_config" {
  description = "S3 bucket logging configuration"
  type = object({
    enabled       = bool
    target_bucket = optional(string)
    target_prefix = optional(string, "logs/")
  })
  default = {
    enabled = false
  }

  validation {
    condition     = !var.logging_config.enabled || (var.logging_config.enabled && var.logging_config.target_bucket != null)
    error_message = "target_bucket must be specified when logging is enabled."
  }
}

variable "cors_rules" {
  description = "List of CORS rules for the bucket"
  type = list(object({
    allowed_headers = optional(list(string), [])
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string), [])
    max_age_seconds = optional(number, 3000)
  }))
  default = []
}

variable "website_config" {
  description = "Static website hosting configuration"
  type = object({
    enabled           = optional(bool, false)
    index_document    = optional(string, "index.html")
    error_document    = optional(string)
    redirect_to       = optional(string)
    redirect_protocol = optional(string, "https")
  })
  default = {}

  validation {
    condition     = !var.website_config.enabled || (var.website_config.enabled && (var.website_config.index_document != null || var.website_config.redirect_to != null))
    error_message = "Either index_document or redirect_to must be specified when website hosting is enabled."
  }
}

variable "block_public_acls" {
  description = "Block public ACLs on this bucket. Recommended: true"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public bucket policies on this bucket. Recommended: true"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs on this bucket. Recommended: true"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public bucket policies for this bucket. Recommended: true"
  type        = bool
  default     = true
}

variable "bucket_policy" {
  description = "Predefined bucket policy configuration. Use 'public' for public read access or 'cloudflare' for Cloudflare-only access."
  type = object({
    name        = string
    permissions = list(string)
  })
  default = null

  validation {
    condition     = var.bucket_policy == null ? true : contains(["public", "cloudflare"], var.bucket_policy.name)
    error_message = "Bucket policy name must be either 'public' or 'cloudflare'."
  }
}

variable "custom_bucket_policy_statements" {
  description = "List of custom IAM policy statements to add to the bucket policy"
  type        = list(any)
  default     = null
}
