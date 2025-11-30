data "cloudflare_zones" "domain" {
  name = var.root_domain
}

resource "cloudflare_dns_record" "this" {
  for_each = var.dns_records

  zone_id = data.cloudflare_zones.domain.result[0].id
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl
  proxied = each.value.proxied
  comment = lookup(each.value, "comment", null)

  # Value/content based on record type (for A, AAAA, CNAME, TXT, NS, MX)
  content = lookup(each.value, "data", null) == null ? each.value.value : null

  # MX, SRV, and URI record specific
  priority = contains(["MX", "SRV", "URI"], each.value.type) ? lookup(each.value, "priority", null) : null

  # SRV and CAA records use the data block
  data = lookup(each.value, "data", null) != null ? each.value.data : null

  tags = lookup(each.value, "tags", [])
}

