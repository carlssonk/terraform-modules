resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, {
    Name = "${var.server_name}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, {
    Name = "${var.server_name}-igw"
  })
}

resource "aws_subnet" "this" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    Name = "${var.server_name}-subnet"
  })
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.tags, {
    Name = "${var.server_name}-rt"
  })
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}

locals {
  tags = merge(
    {
      Environment = terraform.workspace
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

resource "tls_private_key" "ssh" {
  count     = var.enable_ssh ? 1 : 0
  algorithm = "ED25519"
}

resource "aws_key_pair" "ssh" {
  count      = var.enable_ssh ? 1 : 0
  key_name   = "${var.server_name}-key"
  public_key = tls_private_key.ssh[0].public_key_openssh

  tags = local.tags
}

module "minecraft_sg" {
  source = "../../modules/security-group"

  name        = "${var.server_name}-sg"
  description = "Security group for Minecraft server"
  vpc_id      = aws_vpc.this.id

  ingress_rules = concat(
    [
      {
        from_port   = 25565
        to_port     = 25565
        protocol    = "tcp"
        cidr_blocks = var.allowed_cidrs
        description = "Minecraft Java Edition"
      }
    ],
    var.enable_ssh ? [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = var.ssh_allowed_cidrs
        description = "SSH access"
      }
    ] : []
  )

  tags = local.tags
}

resource "aws_ebs_volume" "minecraft_data" {
  availability_zone = var.availability_zone
  size              = var.data_volume_size
  type              = "gp3"
  encrypted         = true

  tags = merge(local.tags, {
    Name = "${var.server_name}-data"
  })

  lifecycle {
    prevent_destroy = true
  }
}

module "minecraft_server" {
  source = "../../modules/ec2"

  name               = var.server_name
  instance_type      = var.instance_type
  key_name           = var.enable_ssh ? aws_key_pair.ssh[0].key_name : null
  subnet_id          = aws_subnet.this.id
  security_group_ids = [module.minecraft_sg.security_group_id]
  associate_eip      = true
  root_volume_size   = var.volume_size

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    minecraft_version = var.minecraft_version
    server_port       = 25565
    max_players       = var.max_players
    motd              = var.motd
    difficulty        = var.difficulty
    gamemode          = var.gamemode
    memory            = var.jvm_memory
    whitelist_enabled = var.whitelist_enabled
    whitelist_players = var.whitelist_players
    enable_rcon       = var.enable_rcon
    rcon_password     = var.rcon_password
    data_device       = "/dev/xvdf"
  })

  tags = local.tags
}

resource "aws_volume_attachment" "minecraft_data" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.minecraft_data.id
  instance_id = module.minecraft_server.instance_id
}

module "minecraft_backups" {
  count  = var.enable_backups ? 1 : 0
  source = "../../modules/s3"

  bucket_name   = "${var.server_name}-backups"
  force_destroy = false

  lifecycle_rules = [
    {
      id              = "expire-old-backups"
      enabled         = true
      prefix          = null
      tags            = null
      expiration_days = var.backup_retention_days
      transitions     = []

      noncurrent_version_transitions        = []
      noncurrent_version_expiration_days     = null
    }
  ]

  tags = local.tags
}
