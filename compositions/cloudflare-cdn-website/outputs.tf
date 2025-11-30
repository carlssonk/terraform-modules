output "subdomain_bucket_name" {
  description = "Name of the subdomain S3 bucket"
  value       = module.subdomain_bucket.bucket_name
}

output "subdomain_bucket_arn" {
  description = "ARN of the subdomain S3 bucket"
  value       = module.subdomain_bucket.bucket_arn
}

output "subdomain_website_endpoint" {
  description = "Website endpoint for the subdomain bucket"
  value       = module.subdomain_bucket.website_endpoint
}

output "subdomain_website_url" {
  description = "Full website URL for the subdomain"
  value       = "https://${local.domain_name}"
}

output "root_bucket_name" {
  description = "Name of the root domain S3 bucket (only if subdomain is 'www')"
  value       = var.subdomain == "www" ? module.root_bucket[0].bucket_name : null
}

output "root_bucket_arn" {
  description = "ARN of the root domain S3 bucket (only if subdomain is 'www')"
  value       = var.subdomain == "www" ? module.root_bucket[0].bucket_arn : null
}

output "root_website_endpoint" {
  description = "Website endpoint for the root domain bucket (only if subdomain is 'www')"
  value       = var.subdomain == "www" ? module.root_bucket[0].website_endpoint : null
}

output "cloudflare_dns_records" {
  description = "Map of created DNS records"
  value       = module.cloudflare_record.dns_records
}

output "domain_name" {
  description = "Full domain name (subdomain.root_domain)"
  value       = local.domain_name
}

