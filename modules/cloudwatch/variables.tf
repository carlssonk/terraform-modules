variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string

  validation {
    condition     = can(regex("^[\\w\\-/.#]+$", var.log_group_name))
    error_message = "Log group name can only contain alphanumeric characters, hyphens, underscores, forward slashes, periods, and hash symbols."
  }
}

variable "retention_in_days" {
  description = "Number of days to retain log events. Valid values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, or 0 (never expire)"
  type        = number
  default     = 30

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.retention_in_days)
    error_message = "Retention must be a valid CloudWatch Logs retention period."
  }
}

variable "kms_key_id" {
  description = "ARN of the KMS key to use for encrypting log data. If not specified, logs are encrypted with AWS managed keys."
  type        = string
  default     = null
}

variable "skip_destroy" {
  description = "Set to true to prevent destruction of the log group. Useful for production log groups."
  type        = bool
  default     = false
}

variable "log_streams" {
  description = "List of log stream names to create in the log group"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

# Metric Alarms
variable "metric_alarms" {
  description = "Map of CloudWatch metric alarms to create"
  type = map(object({
    alarm_name          = string
    alarm_description   = optional(string)
    comparison_operator = string # GreaterThanThreshold, GreaterThanOrEqualToThreshold, LessThanThreshold, LessThanOrEqualToThreshold, etc.
    evaluation_periods  = number
    metric_name         = optional(string)
    namespace           = optional(string)
    period              = optional(number)
    statistic           = optional(string) # SampleCount, Average, Sum, Minimum, Maximum
    threshold           = number
    datapoints_to_alarm = optional(number)
    treat_missing_data  = optional(string) # missing, notBreaching, breaching, ignore
    unit                = optional(string)
    dimensions          = optional(map(string))
    alarm_actions       = optional(list(string))
    ok_actions          = optional(list(string))
    insufficient_data_actions = optional(list(string))
    metric_queries      = optional(list(object({
      id          = string
      expression  = optional(string)
      label       = optional(string)
      return_data = optional(bool)
      metric = optional(object({
        metric_name = string
        namespace   = string
        period      = number
        stat        = string
        unit        = optional(string)
        dimensions  = optional(map(string))
      }))
    })))
  }))
  default = {}
}

# Log Metric Filters
variable "log_metric_filters" {
  description = "Map of log metric filters to create custom metrics from log events"
  type = map(object({
    name    = string
    pattern = string
    metric_transformation = object({
      name          = string
      namespace     = string
      value         = string
      default_value = optional(number)
      dimensions    = optional(map(string))
      unit          = optional(string)
    })
  }))
  default = {}
}

# Log Subscription Filters
variable "log_subscription_filters" {
  description = "Map of subscription filters to stream log data to other services (Lambda, Kinesis, Firehose)"
  type = map(object({
    name            = string
    filter_pattern  = string
    destination_arn = string
    role_arn        = optional(string)
    distribution    = optional(string) # ByLogStream or Random
  }))
  default = {}
}

# Log Resource Policy
variable "log_resource_policy" {
  description = "CloudWatch Logs resource policy for cross-account access"
  type = object({
    policy_name     = string
    policy_document = string
  })
  default = null
}

# Dashboard
variable "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  type        = string
  default     = null
}

variable "dashboard_body" {
  description = "JSON-formatted dashboard body. See AWS CloudWatch Dashboard Body Structure documentation."
  type        = string
  default     = null
}

# Composite Alarms
variable "composite_alarms" {
  description = "Map of composite alarms that combine multiple alarms using boolean logic"
  type = map(object({
    alarm_name        = string
    alarm_description = optional(string)
    actions_enabled   = optional(bool)
    alarm_actions     = optional(list(string))
    ok_actions        = optional(list(string))
    alarm_rule        = string # Boolean expression combining other alarms
    actions_suppressor = optional(object({
      alarm            = string
      extension_period = number
      wait_period      = number
    }))
  }))
  default = {}
}

