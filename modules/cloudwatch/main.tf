resource "aws_cloudwatch_log_group" "this" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_id
  skip_destroy      = var.skip_destroy

  tags = var.tags
}

resource "aws_cloudwatch_log_stream" "this" {
  for_each       = toset(var.log_streams)
  name           = each.value
  log_group_name = aws_cloudwatch_log_group.this.name
}

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = var.metric_alarms

  alarm_name          = each.value.alarm_name
  alarm_description   = lookup(each.value, "alarm_description", null)
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = lookup(each.value, "metric_name", null)
  namespace           = lookup(each.value, "namespace", null)
  period              = lookup(each.value, "period", null)
  statistic           = lookup(each.value, "statistic", null)
  threshold           = each.value.threshold
  datapoints_to_alarm = lookup(each.value, "datapoints_to_alarm", null)
  treat_missing_data  = lookup(each.value, "treat_missing_data", "missing")
  unit                = lookup(each.value, "unit", null)

  dimensions = lookup(each.value, "dimensions", null)

  alarm_actions             = lookup(each.value, "alarm_actions", [])
  ok_actions                = lookup(each.value, "ok_actions", [])
  insufficient_data_actions = lookup(each.value, "insufficient_data_actions", [])

  dynamic "metric_query" {
    for_each = lookup(each.value, "metric_queries", [])
    content {
      id          = metric_query.value.id
      expression  = lookup(metric_query.value, "expression", null)
      label       = lookup(metric_query.value, "label", null)
      return_data = lookup(metric_query.value, "return_data", null)

      dynamic "metric" {
        for_each = lookup(metric_query.value, "metric", null) != null ? [metric_query.value.metric] : []
        content {
          metric_name = metric.value.metric_name
          namespace   = metric.value.namespace
          period      = metric.value.period
          stat        = metric.value.stat
          unit        = lookup(metric.value, "unit", null)
          dimensions  = lookup(metric.value, "dimensions", null)
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each = var.log_metric_filters

  name           = each.value.name
  log_group_name = aws_cloudwatch_log_group.this.name
  pattern        = each.value.pattern

  metric_transformation {
    name          = each.value.metric_transformation.name
    namespace     = each.value.metric_transformation.namespace
    value         = each.value.metric_transformation.value
    default_value = lookup(each.value.metric_transformation, "default_value", null)
    dimensions    = lookup(each.value.metric_transformation, "dimensions", null)
    unit          = lookup(each.value.metric_transformation, "unit", null)
  }
}

resource "aws_cloudwatch_log_subscription_filter" "this" {
  for_each = var.log_subscription_filters

  name            = each.value.name
  log_group_name  = aws_cloudwatch_log_group.this.name
  filter_pattern  = each.value.filter_pattern
  destination_arn = each.value.destination_arn
  role_arn        = lookup(each.value, "role_arn", null)
  distribution    = lookup(each.value, "distribution", null)
}

resource "aws_cloudwatch_log_resource_policy" "this" {
  count = var.log_resource_policy != null ? 1 : 0

  policy_name     = var.log_resource_policy.policy_name
  policy_document = var.log_resource_policy.policy_document
}

resource "aws_cloudwatch_dashboard" "this" {
  count = var.dashboard_body != null ? 1 : 0

  dashboard_name = var.dashboard_name != null ? var.dashboard_name : "${var.log_group_name}-dashboard"
  dashboard_body = var.dashboard_body
}

resource "aws_cloudwatch_composite_alarm" "this" {
  for_each = var.composite_alarms

  alarm_name          = each.value.alarm_name
  alarm_description   = lookup(each.value, "alarm_description", null)
  actions_enabled     = lookup(each.value, "actions_enabled", true)
  alarm_actions       = lookup(each.value, "alarm_actions", [])
  ok_actions          = lookup(each.value, "ok_actions", [])
  alarm_rule          = each.value.alarm_rule

  dynamic "actions_suppressor" {
    for_each = lookup(each.value, "actions_suppressor", null) != null ? [each.value.actions_suppressor] : []
    content {
      alarm             = actions_suppressor.value.alarm
      extension_period  = actions_suppressor.value.extension_period
      wait_period       = actions_suppressor.value.wait_period
    }
  }

  tags = var.tags
}

