resource "cloudflare_ruleset" "this" {
  count       = var.enabled ? 1 : 0
  account_id  = var.account_id
  zone_id     = var.zone_id
  name        = var.name
  description = var.description
  kind        = var.kind
  phase       = var.phase
  rules       = var.rules
}
