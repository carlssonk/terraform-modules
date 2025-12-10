variable "stack_name" {
  description = "Name of the CloudFormation stack"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][-a-zA-Z0-9]*$", var.stack_name)) && length(var.stack_name) >= 1 && length(var.stack_name) <= 128
    error_message = "Stack name must be between 1 and 128 characters, start with a letter, and contain only alphanumeric characters and hyphens."
  }
}

variable "template_body" {
  description = "CloudFormation template body in JSON or YAML format. Either template_body or template_url must be specified."
  type        = string
  default     = null

  validation {
    condition     = var.template_body == null || (var.template_body != null && length(var.template_body) > 0)
    error_message = "If template_body is specified, it must not be empty."
  }
}

variable "template_url" {
  description = "URL to CloudFormation template in S3. Either template_body or template_url must be specified."
  type        = string
  default     = null

  validation {
    condition     = var.template_url == null || (var.template_url != null && can(regex("^https://", var.template_url)))
    error_message = "If template_url is specified, it must be a valid HTTPS URL."
  }
}

variable "parameters" {
  description = "Map of input parameters for the CloudFormation stack"
  type        = map(string)
  default     = {}
}

variable "capabilities" {
  description = "List of capabilities required by the stack. Valid values: CAPABILITY_IAM, CAPABILITY_NAMED_IAM, CAPABILITY_AUTO_EXPAND"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cap in var.capabilities :
      contains(["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"], cap)
    ])
    error_message = "Capabilities must be one of: CAPABILITY_IAM, CAPABILITY_NAMED_IAM, CAPABILITY_AUTO_EXPAND."
  }
}

variable "iam_role_arn" {
  description = "ARN of an IAM role that CloudFormation assumes to create the stack"
  type        = string
  default     = null

  validation {
    condition     = var.iam_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/", var.iam_role_arn))
    error_message = "If iam_role_arn is specified, it must be a valid IAM role ARN."
  }
}

variable "on_failure" {
  description = "Action to take if stack creation fails. Valid values: DO_NOTHING, ROLLBACK, DELETE"
  type        = string
  default     = "ROLLBACK"

  validation {
    condition     = contains(["DO_NOTHING", "ROLLBACK", "DELETE"], var.on_failure)
    error_message = "on_failure must be one of: DO_NOTHING, ROLLBACK, DELETE."
  }
}

variable "timeout_in_minutes" {
  description = "Amount of time in minutes that can pass before the stack creation times out"
  type        = number
  default     = null

  validation {
    condition     = var.timeout_in_minutes == null || (var.timeout_in_minutes >= 1 && var.timeout_in_minutes <= 43200)
    error_message = "If timeout_in_minutes is specified, it must be between 1 and 43200 (30 days)."
  }
}

variable "notification_arns" {
  description = "List of SNS topic ARNs to publish stack related events"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for arn in var.notification_arns :
      can(regex("^arn:aws:sns:", arn))
    ])
    error_message = "All notification ARNs must be valid SNS topic ARNs."
  }
}

variable "policy_body" {
  description = "Stack policy body in JSON format. Defines resources that can be updated during a stack update."
  type        = string
  default     = null
}

variable "policy_url" {
  description = "URL to a file containing the stack policy. The URL must point to a policy (max size: 16KB) in an S3 bucket."
  type        = string
  default     = null

  validation {
    condition     = var.policy_url == null || (var.policy_url != null && can(regex("^https://", var.policy_url)))
    error_message = "If policy_url is specified, it must be a valid HTTPS URL."
  }
}

variable "tags" {
  description = "A map of tags to assign to the CloudFormation stack"
  type        = map(string)
  default     = {}
}

variable "ignore_changes" {
  description = "List of attribute paths to ignore changes for"
  type        = list(string)
  default     = []
}

