output "worker_id" {
  description = "ID of the Cloudflare Worker"
  value       = cloudflare_workers_script.this.id
}

output "worker_name" {
  description = "Name of the Cloudflare Worker"
  value       = cloudflare_workers_script.this.script_name
}

output "worker_etag" {
  description = "Hashed script content, can be used in a If-None-Match header when updating"
  value       = cloudflare_workers_script.this.etag
}

output "routes" {
  description = "Map of created worker routes"
  value = {
    for k, v in cloudflare_worker_route.this : k => {
      id      = v.id
      pattern = v.pattern
    }
  }
}

output "zone_id" {
  description = "Cloudflare zone ID where the worker is attached"
  value       = local.zone_id
}

