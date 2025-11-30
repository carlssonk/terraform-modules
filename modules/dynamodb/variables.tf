variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]+$", var.table_name)) && length(var.table_name) >= 3 && length(var.table_name) <= 255
    error_message = "Table name must be between 3 and 255 characters and contain only alphanumeric characters, hyphens, underscores, and periods."
  }
}

variable "billing_mode" {
  description = "Billing mode for the table. Valid values: PROVISIONED or PAY_PER_REQUEST"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "Billing mode must be either PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key"
  type        = string
}

variable "range_key" {
  description = "The attribute to use as the range (sort) key. Optional."
  type        = string
  default     = null
}

variable "attributes" {
  description = "List of attribute definitions. Only define attributes used in keys or indexes."
  type = list(object({
    name = string
    type = string # S (string), N (number), or B (binary)
  }))

  validation {
    condition = alltrue([
      for attr in var.attributes :
      contains(["S", "N", "B"], attr.type)
    ])
    error_message = "Attribute type must be S (string), N (number), or B (binary)."
  }
}

variable "read_capacity" {
  description = "Number of read units for PROVISIONED billing mode"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Number of write units for PROVISIONED billing mode"
  type        = number
  default     = 5
}

variable "table_class" {
  description = "Storage class of the table. Valid values: STANDARD or STANDARD_INFREQUENT_ACCESS"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "Table class must be either STANDARD or STANDARD_INFREQUENT_ACCESS."
  }
}

variable "ttl_enabled" {
  description = "Enable Time to Live (TTL) for automatic item expiration"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Name of the table attribute to store the TTL timestamp"
  type        = string
  default     = "ttl"
}

variable "point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery for the table. Recommended for production."
  type        = bool
  default     = true
}

variable "server_side_encryption_enabled" {
  description = "Enable server-side encryption. Enabled by default with AWS managed keys."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of the CMK to use for encryption. If not specified, uses AWS managed key."
  type        = string
  default     = null
}

variable "stream_enabled" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type. Valid values: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"

  validation {
    condition     = contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "Stream view type must be one of: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  }
}

variable "global_secondary_indexes" {
  description = "List of global secondary indexes"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = string # ALL, KEYS_ONLY, or INCLUDE
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for gsi in var.global_secondary_indexes :
      contains(["ALL", "KEYS_ONLY", "INCLUDE"], gsi.projection_type)
    ])
    error_message = "GSI projection_type must be ALL, KEYS_ONLY, or INCLUDE."
  }
}

variable "local_secondary_indexes" {
  description = "List of local secondary indexes"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string # ALL, KEYS_ONLY, or INCLUDE
    non_key_attributes = optional(list(string))
  }))
  default = []

  validation {
    condition = alltrue([
      for lsi in var.local_secondary_indexes :
      contains(["ALL", "KEYS_ONLY", "INCLUDE"], lsi.projection_type)
    ])
    error_message = "LSI projection_type must be ALL, KEYS_ONLY, or INCLUDE."
  }
}

variable "replica_regions" {
  description = "List of AWS regions to replicate this table to for global tables"
  type        = list(string)
  default     = []
}

variable "replica_kms_key_arns" {
  description = "Map of region to KMS key ARN for replica encryption"
  type        = map(string)
  default     = null
}

variable "propagate_tags_to_replicas" {
  description = "Whether to propagate tags to table replicas"
  type        = bool
  default     = true
}

variable "deletion_protection_enabled" {
  description = "Enable deletion protection. Recommended for production tables."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the table"
  type        = map(string)
  default     = {}
}

variable "ignore_changes" {
  description = "List of attribute paths to ignore changes for"
  type        = list(string)
  default     = []
}

