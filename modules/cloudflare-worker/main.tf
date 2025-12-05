data "cloudflare_zones" "this" {
  name = var.zone_name
}

locals {
  zone_id = data.cloudflare_zones.this.result[0].id
}

# Create the Worker script using the v5.0 resource
resource "cloudflare_workers_script" "this" {
  account_id  = var.account_id
  script_name = var.worker_name
  content     = var.worker_script

  # Compatibility settings
  compatibility_date  = var.compatibility_date
  compatibility_flags = var.compatibility_flags

  # Build bindings list with proper structure for v5.0
  bindings = concat(
    # Secret text bindings
    [for key, value in var.secrets : {
      name = key
      text = value
      type = "secret_text"
    }],
    # Plain text bindings
    [for key, value in var.plain_text_bindings : {
      name = key
      text = value
      type = "plain_text"
    }],
    # KV namespace bindings
    [for key, value in var.kv_namespaces : {
      name         = key
      namespace_id = value
      type         = "kv_namespace"
    }]
  )

  # Optional: Logpush setting
  logpush = var.logpush
}

# Create Worker routes to attach the worker to a zone
resource "cloudflare_worker_route" "this" {
  for_each = var.routes

  zone_id = local.zone_id
  pattern = each.value.pattern
  # Reference the script_name from the worker script resource
  script_name = cloudflare_workers_script.this.script_name
}


