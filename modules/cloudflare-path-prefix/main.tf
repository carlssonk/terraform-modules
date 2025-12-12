module "path_prefix_ruleset" {
  source      = "../cloudflare-ruleset"
  enabled     = var.enabled
  zone_id     = var.zone_id
  name        = var.name != "" ? var.name : "Path prefix rewrite - ${var.path_prefix}"
  description = var.description != "" ? var.description : "Rewrite URLs to prefix with ${var.path_prefix}"
  kind        = "zone"
  phase       = "http_request_transform"

  rules = [
    {
      action      = "rewrite"
      description = var.rule_description != "" ? var.rule_description : "Add ${var.path_prefix} prefix to all requests"
      enabled     = true
      expression  = var.expression

      action_parameters = {
        uri = {
          path = {
            expression = "concat(\"${var.path_prefix}\", http.request.uri.path)"
          }
        }
      }
    }
  ]
}

