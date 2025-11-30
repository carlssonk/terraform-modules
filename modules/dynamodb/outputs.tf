output "table_name" {
  description = "The name of the DynamoDB table"
  value       = aws_dynamodb_table.this.name
}

output "table_id" {
  description = "The ID of the DynamoDB table"
  value       = aws_dynamodb_table.this.id
}

output "table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = aws_dynamodb_table.this.arn
}

output "table_stream_arn" {
  description = "The ARN of the table stream (if enabled)"
  value       = try(aws_dynamodb_table.this.stream_arn, null)
}

output "table_stream_label" {
  description = "The stream label of the table (if enabled)"
  value       = try(aws_dynamodb_table.this.stream_label, null)
}

output "hash_key" {
  description = "The hash (partition) key of the table"
  value       = aws_dynamodb_table.this.hash_key
}

output "range_key" {
  description = "The range (sort) key of the table"
  value       = aws_dynamodb_table.this.range_key
}

