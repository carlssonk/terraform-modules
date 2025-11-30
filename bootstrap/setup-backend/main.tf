// Bootstraps terraform backend for a new environment
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.organization}-terraform-state-bucket-${terraform.workspace}"

  tags = {
    Name        = "${var.organization}-terraform-state-bucket-${terraform.workspace}"
    Environment = terraform.workspace
    Purpose     = "terraform-state"
    ManagedBy   = "terraform"
    Component   = "bootstrap"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "this" {
  name         = "${var.organization}-terraform-lock-table-${terraform.workspace}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "${var.organization}-terraform-lock-table-${terraform.workspace}"
    Environment = terraform.workspace
    Purpose     = "terraform-lock"
    ManagedBy   = "terraform"
    Component   = "bootstrap"
  }
}
