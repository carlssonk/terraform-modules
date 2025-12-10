output "stack_id" {
  description = "Unique identifier of the CloudFormation stack"
  value       = module.runs_on.stack_id
}

output "stack_name" {
  description = "Name of the CloudFormation stack"
  value       = module.runs_on.stack_name
}

output "stack_outputs" {
  description = "Map of outputs from the CloudFormation stack"
  value       = module.runs_on.stack_outputs
}

output "organization" {
  description = "GitHub organization configured for the runners"
  value       = var.organization
}

output "template_url" {
  description = "URL of the CloudFormation template used"
  value       = "https://runs-on.s3.eu-west-1.amazonaws.com/cloudformation/template-${var.template_version}.yaml"
}

output "dashboard_url" {
  description = "CloudWatch dashboard URL (if enabled)"
  value       = var.enable_dashboard ? "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${var.stack_name}" : null
}

