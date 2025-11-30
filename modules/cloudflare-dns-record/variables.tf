variable "root_domain" {
  description = "The root domain name for zone lookup (e.g., example.com)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)*$", var.root_domain))
    error_message = "Root domain must be a valid domain name."
  }
}

variable "dns_records" {
  description = "Map of DNS records to create. Key is a unique identifier, value is the record configuration."
  type = map(object({
    name     = string
    value    = string
    type     = optional(string, "CNAME")
    ttl      = optional(number, 1) # 1 = automatic, or specify seconds
    proxied  = optional(bool, true)
    priority = optional(number) # For MX, SRV, and URI records
    comment  = optional(string)
    tags     = optional(list(string), [])
    data = optional(object({
      # For SRV records
      service  = optional(string)
      priority = optional(number)
      weight   = optional(number)
      port     = optional(number)
      target   = optional(string)
      # For CAA records
      flags = optional(number)
      tag   = optional(string)
      value = optional(string)
    }))
  }))

  validation {
    condition = alltrue([
      for record in var.dns_records :
      contains(["A", "AAAA", "CNAME", "TXT", "MX", "NS", "SRV", "CAA", "PTR", "SPF"], record.type)
    ])
    error_message = "DNS record type must be one of: A, AAAA, CNAME, TXT, MX, NS, SRV, CAA, PTR, SPF."
  }

  validation {
    condition = alltrue([
      for record in var.dns_records :
      record.ttl == 1 || (record.ttl >= 60 && record.ttl <= 86400)
    ])
    error_message = "TTL must be 1 (automatic) or between 60 and 86400 seconds."
  }
}

