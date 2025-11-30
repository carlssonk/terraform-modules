# Cloudflare Zone Module

⚠️ **ZONE-SCOPED MODULE**

This module manages **zone-level** Cloudflare resources that can only be declared **ONCE per Cloudflare zone**.

## Important: Environment Scoping

**DO NOT instantiate this module per environment.** The resources managed here apply to the entire zone and cannot be duplicated.

### Resources Managed (Zone-Level Only)

- **`cloudflare_zone_setting`** - Individual zone settings (SSL, security, performance, etc.)
  - Only ONE settings override per zone
  - Applies to ALL subdomains and environments within the zone

- **`cloudflare_ruleset`** - Zone-level rulesets for configuration
  - Only ONE ruleset per zone per phase (e.g., `http_config_settings`)
  - Rules can target specific hosts/environments via expressions, but the ruleset itself is singular

## Usage Pattern

### ❌ WRONG - Don't do this:
```hcl
# This will FAIL or cause conflicts!
module "cloudflare_dev" {
  source       = "../../modules/cloudflare-zone"
  environments = ["dev"]
  # ...
}

module "cloudflare_production" {
  source       = "../../modules/cloudflare-zone"
  environments = ["production"]
  # ...
}
```

### ✅ CORRECT - Do this:
```hcl
# Single instance with all environments
module "cloudflare_zone" {
  source       = "../../modules/cloudflare-zone"
  environments = ["dev", "staging", "production"]  # All environments in one declaration
  apps = {
    my_app = {
      app_name    = "my-app"
      root_domain = "example.com"
      subdomain   = "app"
      cloudflare = {
        ssl_mode = "strict"
      }
    }
  }
}
```