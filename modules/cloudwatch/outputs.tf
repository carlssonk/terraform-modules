output "log_group_name" {
  description = "The name of the log group"
  value       = aws_cloudwatch_log_group.this.name
}

output "log_group_arn" {
  description = "The ARN of the log group"
  value       = aws_cloudwatch_log_group.this.arn
}

output "log_group_retention_in_days" {
  description = "The retention period of the log group"
  value       = aws_cloudwatch_log_group.this.retention_in_days
}

output "log_streams" {
  description = "Map of log stream names to their ARNs"
  value = {
    for name, stream in aws_cloudwatch_log_stream.this :
    name => stream.arn
  }
}

output "metric_alarms" {
  description = "Map of metric alarm names to their ARNs"
  value = {
    for name, alarm in aws_cloudwatch_metric_alarm.this :
    name => alarm.arn
  }
}

output "log_metric_filters" {
  description = "Map of log metric filter names"
  value = {
    for name, filter in aws_cloudwatch_log_metric_filter.this :
    name => filter.id
  }
}

output "dashboard_arn" {
  description = "The ARN of the CloudWatch dashboard (if created)"
  value       = try(aws_cloudwatch_dashboard.this[0].dashboard_arn, null)
}

output "composite_alarms" {
  description = "Map of composite alarm names to their ARNs"
  value = {
    for name, alarm in aws_cloudwatch_composite_alarm.this :
    name => alarm.arn
  }
}

