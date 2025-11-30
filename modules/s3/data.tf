data "http" "cloudflare_ips_v4" {
  count = var.bucket_policy != null && var.bucket_policy.name == "cloudflare" ? 1 : 0
  url   = "https://www.cloudflare.com/ips-v4"
  request_headers = {
    Accept = "text/plain"
  }
}

data "http" "cloudflare_ips_v6" {
  count = var.bucket_policy != null && var.bucket_policy.name == "cloudflare" ? 1 : 0
  url   = "https://www.cloudflare.com/ips-v6"
  request_headers = {
    Accept = "text/plain"
  }
}

locals {
  cloudflare_ipv4_ranges   = var.bucket_policy != null && var.bucket_policy.name == "cloudflare" ? split("\n", chomp(try(data.http.cloudflare_ips_v4[0].response_body, ""))) : []
  cloudflare_ipv6_ranges   = var.bucket_policy != null && var.bucket_policy.name == "cloudflare" ? split("\n", chomp(try(data.http.cloudflare_ips_v6[0].response_body, ""))) : []
  cloudflare_all_ip_ranges = concat(local.cloudflare_ipv4_ranges, local.cloudflare_ipv6_ranges)
}