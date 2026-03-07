output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "The private IP address of the instance"
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "The public IP address (Elastic IP if enabled, otherwise instance public IP)"
  value       = var.associate_eip ? aws_eip.this[0].public_ip : aws_instance.this.public_ip
}

output "instance_arn" {
  description = "The ARN of the EC2 instance"
  value       = aws_instance.this.arn
}
