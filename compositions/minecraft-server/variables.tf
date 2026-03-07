variable "server_name" {
  description = "Name for the Minecraft server resources"
  type        = string
  default     = "minecraft-server"
}

variable "instance_type" {
  description = "EC2 instance type. t3.medium (2 vCPU, 4GB RAM) works for a few friends. Use t3.large for 10+ players."
  type        = string
  default     = "t3.medium"
}

variable "availability_zone" {
  description = "Availability zone for the instance and data volume. Must match so the volume can be attached."
  type        = string
}

variable "volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 20
}

variable "data_volume_size" {
  description = "Size of the persistent EBS data volume in GB (stores the Minecraft world)"
  type        = number
  default     = 20
}

variable "minecraft_version" {
  description = "Minecraft server version to install"
  type        = string
  default     = "1.21.4"
}

variable "max_players" {
  description = "Maximum number of players allowed on the server"
  type        = number
  default     = 10
}

variable "motd" {
  description = "Message of the day shown in the server list"
  type        = string
  default     = "A Minecraft Server"
}

variable "difficulty" {
  description = "Server difficulty: peaceful, easy, normal, hard"
  type        = string
  default     = "normal"

  validation {
    condition     = contains(["peaceful", "easy", "normal", "hard"], var.difficulty)
    error_message = "Difficulty must be one of: peaceful, easy, normal, hard."
  }
}

variable "gamemode" {
  description = "Default game mode: survival, creative, adventure, spectator"
  type        = string
  default     = "survival"

  validation {
    condition     = contains(["survival", "creative", "adventure", "spectator"], var.gamemode)
    error_message = "Gamemode must be one of: survival, creative, adventure, spectator."
  }
}

variable "jvm_memory" {
  description = "Memory allocation for the JVM (e.g., 2G, 3G). Leave ~1GB for the OS."
  type        = string
  default     = "3G"
}

variable "use_spot" {
  description = "Use a spot instance to save costs. The instance will be stopped (not terminated) if AWS reclaims capacity."
  type        = bool
  default     = false
}

variable "spot_max_price" {
  description = "Maximum hourly price for the spot instance. Null means the on-demand price."
  type        = string
  default     = null
}

variable "allowed_cidrs" {
  description = "CIDR blocks allowed to connect to the Minecraft server. Use [\"0.0.0.0/0\"] for public access."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_ssh" {
  description = "Enable SSH access to the server. Generates a key pair automatically."
  type        = bool
  default     = false
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "whitelist_enabled" {
  description = "Enable server whitelist. Only players in whitelist_players can join."
  type        = bool
  default     = false
}

variable "whitelist_players" {
  description = "List of player names to whitelist. Requires whitelist_enabled = true."
  type        = list(string)
  default     = []
}

variable "enable_rcon" {
  description = "Enable RCON (remote console) for server management"
  type        = bool
  default     = false
}

variable "rcon_password" {
  description = "Password for RCON access (required if enable_rcon is true)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_backups" {
  description = "Enable automatic world backups to S3"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Number of days to retain world backups in S3"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags to assign to resources"
  type        = map(string)
  default     = {}
}
