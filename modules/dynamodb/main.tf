resource "aws_dynamodb_table" "this" {
  name             = var.table_name
  billing_mode     = var.billing_mode
  hash_key         = var.hash_key
  range_key        = var.range_key
  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null
  table_class      = var.table_class

  # Only specify read/write capacity for PROVISIONED mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  # Time to Live (TTL) - Cost optimization and data management
  dynamic "ttl" {
    for_each = var.ttl_enabled ? [1] : []
    content {
      enabled        = true
      attribute_name = var.ttl_attribute_name
    }
  }

  # Point-in-time recovery - Data protection best practice
  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  # Server-side encryption - Security best practice
  server_side_encryption {
    enabled     = var.server_side_encryption_enabled
    kms_key_arn = var.server_side_encryption_enabled && var.kms_key_arn != null ? var.kms_key_arn : null
  }

  # Attributes - Define all attributes used in keys and indexes
  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  # Global Secondary Indexes (GSI)
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
      read_capacity      = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "read_capacity", null) : null
      write_capacity     = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "write_capacity", null) : null
    }
  }

  # Local Secondary Indexes (LSI)
  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = lookup(local_secondary_index.value, "non_key_attributes", null)
    }
  }

  # Replica configuration for global tables
  dynamic "replica" {
    for_each = var.replica_regions
    content {
      region_name            = replica.value
      kms_key_arn            = var.replica_kms_key_arns != null ? lookup(var.replica_kms_key_arns, replica.value, null) : null
      propagate_tags         = var.propagate_tags_to_replicas
      point_in_time_recovery = var.point_in_time_recovery_enabled
    }
  }

  deletion_protection_enabled = var.deletion_protection_enabled

  tags = var.tags

  lifecycle {
    ignore_changes = var.ignore_changes
  }
}