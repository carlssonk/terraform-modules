resource "aws_cloudformation_stack" "this" {
  name          = var.stack_name
  template_body = var.template_body
  template_url  = var.template_url

  parameters    = var.parameters
  capabilities  = var.capabilities
  iam_role_arn  = var.iam_role_arn
  on_failure    = var.on_failure
  timeout_in_minutes = var.timeout_in_minutes

  notification_arns = var.notification_arns
  policy_body       = var.policy_body
  policy_url        = var.policy_url

  tags = var.tags
}

