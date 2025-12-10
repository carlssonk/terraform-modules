variable "organization" {
  description = "GitHub organization name"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$", var.organization)) && length(var.organization) >= 1 && length(var.organization) <= 39
    error_message = "Organization name must be between 1 and 39 characters, start and end with alphanumeric characters, and contain only alphanumeric characters and hyphens."
  }
}

variable "license_key" {
  description = "RunsOn license key or SSM parameter ARN containing the license key"
  type        = string
  sensitive   = true
}

variable "email" {
  description = "Email address for notifications and alerts"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.email))
    error_message = "Email must be a valid email address."
  }
}

variable "template_version" {
  description = "Version of the RunsOn CloudFormation template to use"
  type        = string
  default     = "v2.10.1"

  validation {
    condition     = can(regex("^v[0-9]+\\.[0-9]+\\.[0-9]+$", var.template_version))
    error_message = "Template version must be in the format vX.Y.Z (e.g., v2.10.1)."
  }
}

variable "stack_name" {
  description = "Name of the CloudFormation stack"
  type        = string
  default     = "runs-on"

  validation {
    condition     = can(regex("^[a-zA-Z][-a-zA-Z0-9]*$", var.stack_name)) && length(var.stack_name) >= 1 && length(var.stack_name) <= 128
    error_message = "Stack name must be between 1 and 128 characters, start with a letter, and contain only alphanumeric characters and hyphens."
  }
}

variable "networking_stack" {
  description = "Networking configuration. Use 'embedded' for automatic VPC creation or specify an existing networking stack name."
  type        = string
  default     = "embedded"
}

variable "cost_reports_enabled" {
  description = "Enable daily cost reports for monitoring runner expenses"
  type        = bool
  default     = true
}

variable "cost_allocation_tag" {
  description = "Tag key to use for AWS cost allocation tracking"
  type        = string
  default     = "stack"
}

variable "enable_dashboard" {
  description = "Enable CloudWatch dashboard for monitoring runner activity"
  type        = bool
  default     = true
}

variable "ec2_log_retention_days" {
  description = "Number of days to retain EC2 instance logs in CloudWatch"
  type        = number
  default     = 7

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.ec2_log_retention_days)
    error_message = "Log retention must be a valid CloudWatch Logs retention period."
  }
}

variable "runner_default_volume_throughput" {
  description = "EBS volume throughput in MiB/s for faster boot times"
  type        = number
  default     = 400

  validation {
    condition     = var.runner_default_volume_throughput >= 125 && var.runner_default_volume_throughput <= 1000
    error_message = "Volume throughput must be between 125 and 1000 MiB/s."
  }
}

variable "runner_default_disk_size" {
  description = "Default disk size in GB for runner instances"
  type        = number
  default     = 40

  validation {
    condition     = var.runner_default_disk_size >= 20 && var.runner_default_disk_size <= 16384
    error_message = "Disk size must be between 20 and 16384 GB."
  }
}

variable "spot_circuit_breaker" {
  description = "Spot instance circuit breaker configuration in format 'failures/minutes/cooldown' (e.g., '2/15/30')"
  type        = string
  default     = "2/15/30"

  validation {
    condition     = can(regex("^[0-9]+/[0-9]+/[0-9]+$", var.spot_circuit_breaker))
    error_message = "Spot circuit breaker must be in format 'failures/minutes/cooldown' (e.g., '2/15/30')."
  }
}

variable "encrypt_ebs" {
  description = "Enable EBS volume encryption for runner instances"
  type        = bool
  default     = true
}

variable "ssh_allowed" {
  description = "Allow SSH access to runner instances for troubleshooting"
  type        = bool
  default     = true
}

variable "ssh_cidr_range" {
  description = "CIDR range allowed for SSH access to runner instances"
  type        = string
  default     = "10.0.0.0/8"

  validation {
    condition     = can(cidrhost(var.ssh_cidr_range, 0))
    error_message = "SSH CIDR range must be a valid CIDR block."
  }
}

variable "environment" {
  description = "Environment name for tagging resources"
  type        = string
  default     = "production"
}

variable "tags" {
  description = "Additional tags to assign to the CloudFormation stack"
  type        = map(string)
  default     = {}
}

