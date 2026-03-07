variable "name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID. If null, uses the latest Amazon Linux 2023 AMI."
  type        = string
  default     = null
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in. If null, uses the default subnet."
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "List of security group IDs to attach"
  type        = list(string)
  default     = []
}

variable "user_data" {
  description = "User data script to run on instance launch"
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 20

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 16384
    error_message = "Root volume size must be between 8 and 16384 GB."
  }
}

variable "root_volume_type" {
  description = "Type of the root EBS volume"
  type        = string
  default     = "gp3"
}

variable "use_spot" {
  description = "Whether to use a spot instance"
  type        = bool
  default     = false
}

variable "spot_max_price" {
  description = "Maximum hourly price for the spot instance. Null means the on-demand price."
  type        = string
  default     = null
}

variable "associate_eip" {
  description = "Whether to create and associate an Elastic IP"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to assign to resources"
  type        = map(string)
  default     = {}
}
