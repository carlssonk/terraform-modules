resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.sse_algorithm == "aws:kms" ? var.kms_master_key_id : null
    }
    bucket_key_enabled = var.sse_algorithm == "aws:kms" ? var.bucket_key_enabled : null
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "filter" {
        for_each = rule.value.prefix != null || try(length(rule.value.tags) > 0, false) ? [1] : []
        content {
          dynamic "and" {
            for_each = rule.value.prefix != null && try(length(rule.value.tags) > 0, false) ? [1] : []
            content {
              prefix = rule.value.prefix
              tags   = rule.value.tags
            }
          }

          prefix = rule.value.prefix != null && !try(length(rule.value.tags) > 0, false) ? rule.value.prefix : null

          dynamic "tag" {
            for_each = rule.value.prefix == null && try(length(rule.value.tags) > 0, false) ? rule.value.tags : {}
            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      dynamic "transition" {
        for_each = rule.value.transitions
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration_days != null ? [1] : []
        content {
          days = rule.value.expiration_days
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transitions
        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration_days != null ? [1] : []
        content {
          noncurrent_days = rule.value.noncurrent_version_expiration_days
        }
      }
    }
  }
}

resource "aws_s3_bucket_logging" "this" {
  count  = var.logging_config.enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id

  target_bucket = var.logging_config.target_bucket
  target_prefix = var.logging_config.target_prefix
}

resource "aws_s3_bucket_cors_configuration" "this" {
  count  = length(var.cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

resource "aws_s3_bucket_website_configuration" "this" {
  count  = var.website_config.enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "index_document" {
    for_each = var.website_config.index_document != null ? [1] : []
    content {
      suffix = var.website_config.index_document
    }
  }

  dynamic "error_document" {
    for_each = var.website_config.error_document != null ? [1] : []
    content {
      key = var.website_config.error_document
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = var.website_config.redirect_to != null ? [1] : []
    content {
      host_name = var.website_config.redirect_to
      protocol  = var.website_config.redirect_protocol
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

locals {
  policy_types = {
    public = {
      Effect    = "Allow"
      Principal = "*"
      Action    = var.bucket_policy.permissions
      Resource = [
        aws_s3_bucket.this.arn,
        "${aws_s3_bucket.this.arn}/*"
      ]
    }
    cloudflare = {
      Effect    = "Allow"
      Principal = "*"
      Action    = var.bucket_policy.permissions
      Resource = [
        aws_s3_bucket.this.arn,
        "${aws_s3_bucket.this.arn}/*"
      ]
      Condition = {
        IpAddress = {
          "aws:SourceIp" = local.cloudflare_all_ip_ranges
        }
      }
    }
    default = null
  }

  policy_statement = var.bucket_policy != null ? lookup(local.policy_types, var.bucket_policy.name, null) : null

  policy_statement_combined = concat(
    local.policy_statement != null ? [local.policy_statement] : [],
    var.custom_bucket_policy_statements != null ? var.custom_bucket_policy_statements : []
  )
}

resource "aws_s3_bucket_policy" "this" {
  count  = length(local.policy_statement_combined) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.policy_statement_combined
  })

  depends_on = [aws_s3_bucket_public_access_block.this]
}
