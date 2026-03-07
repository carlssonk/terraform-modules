output "server_ip" {
  description = "Public IP address of the Minecraft server. Connect using this IP in Minecraft."
  value       = module.minecraft_server.public_ip
}

output "server_address" {
  description = "Full server address to share with friends (IP:port)"
  value       = "${module.minecraft_server.public_ip}:25565"
}

output "instance_id" {
  description = "EC2 instance ID (useful for starting/stopping the server via AWS CLI)"
  value       = module.minecraft_server.instance_id
}

output "backup_bucket" {
  description = "S3 bucket name for world backups"
  value       = var.enable_backups ? module.minecraft_backups[0].bucket_id : null
}

output "ssh_private_key" {
  description = "Private SSH key for connecting to the server. Save to a file and use: ssh -i key.pem ec2-user@<server_ip>"
  value       = var.enable_ssh ? tls_private_key.ssh[0].private_key_openssh : null
  sensitive   = true
}

output "ssh_command" {
  description = "SSH command to connect to the server"
  value       = var.enable_ssh ? "ssh -i minecraft-key.pem ec2-user@${module.minecraft_server.public_ip}" : null
}
