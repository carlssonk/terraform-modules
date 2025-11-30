data "cloudflare_zones" "domain" {
  name = var.root_domain
}

resource "cloudflare_record" "this" {
  for_each = var.dns_records

  zone_id         = data.cloudflare_zones.domain.result[0].id
  name            = each.value.name
  type            = each.value.type
  ttl             = each.value.ttl
  proxied         = each.value.proxied
  allow_overwrite = lookup(each.value, "allow_overwrite", false)
  comment         = lookup(each.value, "comment", null)

  # Value/content based on record type
  value = contains(["A", "AAAA", "CNAME", "TXT", "NS"], each.value.type) ? each.value.value : null

  # MX record specific
  priority = each.value.type == "MX" ? lookup(each.value, "priority", null) : null

  # SRV record specific
  dynamic "data" {
    for_each = each.value.type == "SRV" && lookup(each.value, "data", null) != null ? [each.value.data] : []
    content {
      service  = data.value.service
      proto    = data.value.proto
      name     = data.value.name
      priority = data.value.priority
      weight   = data.value.weight
      port     = data.value.port
      target   = data.value.target
    }
  }

  # CAA record specific
  dynamic "data" {
    for_each = each.value.type == "CAA" && lookup(each.value, "data", null) != null ? [each.value.data] : []
    content {
      flags = data.value.flags
      tag   = data.value.tag
      value = data.value.value
    }
  }

  tags = lookup(each.value, "tags", [])
}

