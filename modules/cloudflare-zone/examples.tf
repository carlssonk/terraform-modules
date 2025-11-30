# Example 1: Basic usage with all defaults
module "basic_zone" {
  source    = "../../modules/cloudflare-zone"
  zone_name = "example.com"
}

# Example 2: Production zone with strict security
module "production_zone" {
  source    = "../../modules/cloudflare-zone"
  zone_name = "mycompany.com"
  
  settings = {
    ssl             = "strict"
    security_level  = "high"
    min_tls_version = "1.3"
  }
}

# Example 3: Development zone with relaxed settings
module "dev_zone" {
  source    = "../../modules/cloudflare-zone"
  zone_name = "dev.mycompany.com"
  
  settings = {
    ssl              = "flexible"
    development_mode = "on"
    security_level   = "low"
  }
}

# Example 4: Performance-optimized zone
module "cdn_zone" {
  source    = "../../modules/cloudflare-zone"
  zone_name = "cdn.example.com"
  
  settings = {
    http3             = "on"
    brotli            = "on"
    "0rtt"            = "on"
    early_hints       = "on"
    browser_cache_ttl = 86400  # 24 hours
  }
}

