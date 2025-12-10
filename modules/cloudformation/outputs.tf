output "stack_id" {
  description = "Unique identifier of the CloudFormation stack"
  value       = aws_cloudformation_stack.this.id
}

output "stack_name" {
  description = "Name of the CloudFormation stack"
  value       = aws_cloudformation_stack.this.name
}

output "stack_outputs" {
  description = "Map of outputs from the CloudFormation stack"
  value       = aws_cloudformation_stack.this.outputs
}

output "stack_parameters" {
  description = "Map of parameters passed to the CloudFormation stack"
  value       = aws_cloudformation_stack.this.parameters
}

output "stack_tags" {
  description = "Map of tags associated with the CloudFormation stack"
  value       = aws_cloudformation_stack.this.tags_all
}

