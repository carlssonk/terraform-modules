# Migration Guide: Cloudflare Provider v4.0 to v5.0

This guide helps you migrate from Cloudflare Provider v4.0 to v5.0 when using the Cloudflare Worker module.

## What Changed

The Cloudflare Provider v5.0 introduced changes to the Workers resources:

### Resource Changes

**v4.0 (Old):**
- Used `cloudflare_worker_script` with nested blocks for bindings
- Bindings used dynamic blocks: `secret_text_binding`, `plain_text_binding`, `kv_namespace_binding`

**v5.0 (New):**
- Uses `cloudflare_workers_script` (note the "s" in workers)
- Bindings are now a list of objects with a `type` attribute
- Added support for compatibility settings and logpush

### Module Updates

The `cloudflare-worker` module has been updated to use the v5.0 syntax automatically. If you're using the module, you only need to update your provider version.

## Migration Steps

### Step 1: Update Provider Version

Update your `terraform` block or provider configuration:

```hcl
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"  # Changed from ~> 4.0
    }
  }
}
```

### Step 2: Update Module Version

If you've pinned the module version, update to use the latest version that supports Cloudflare Provider v5.0.

### Step 3: Optional - Add New Features

Take advantage of new v5.0 features:

```hcl
module "website" {
  source = "../../compositions/cloudflare-cdn-website"

  # ... existing configuration ...

  # New: Compatibility settings for better runtime control
  worker_compatibility_date  = "2024-01-01"
  worker_compatibility_flags = ["nodejs_compat"]

  # New: Enable Logpush for worker logs
  worker_logpush = true
}
```

### Step 4: Run Terraform Plan

Check what changes Terraform will make:

```bash
terraform init -upgrade
terraform plan
```

**Expected changes:**
- The worker resource will be recreated (due to resource type change)
- No changes to functionality - the worker will continue to work the same way

### Step 5: Apply Changes

```bash
terraform apply
```

**Note:** The worker will be briefly unavailable during the recreation. For production environments, consider:
- Scheduling during low-traffic periods
- Having a backup or fallback mechanism

## Breaking Changes

### None for Module Users

If you're using the `cloudflare-worker` module or `cloudflare-cdn-website` composition, there are **no breaking changes** to your configuration. The module handles all the v5.0 changes internally.

### If Using Raw Resources

If you were directly using `cloudflare_worker_script` (not through our module), you'll need to:

1. Rename to `cloudflare_workers_script`
2. Convert dynamic binding blocks to a list format
3. Update binding syntax to use `type` attribute

**Before (v4.0):**
```hcl
resource "cloudflare_worker_script" "example" {
  account_id = var.account_id
  name       = "my-worker"
  content    = file("worker.js")

  secret_text_binding {
    name = "API_KEY"
    text = var.api_key
  }

  plain_text_binding {
    name = "BUCKET"
    text = "my-bucket"
  }
}
```

**After (v5.0):**
```hcl
resource "cloudflare_workers_script" "example" {
  account_id  = var.account_id
  script_name = "my-worker"
  content     = file("worker.js")

  bindings = [
    {
      name = "API_KEY"
      text = var.api_key
      type = "secret_text"
    },
    {
      name = "BUCKET"
      text = "my-bucket"
      type = "plain_text"
    }
  ]
}
```

## New Features Available

### 1. Compatibility Date

Control which version of the Workers runtime to target:

```hcl
worker_compatibility_date = "2024-01-01"
```

### 2. Compatibility Flags

Enable specific runtime features:

```hcl
worker_compatibility_flags = ["nodejs_compat", "streams_enable_constructors"]
```

### 3. Logpush

Push worker logs to external destinations:

```hcl
worker_logpush = true
```

Configure destinations in the Cloudflare dashboard.

## Rollback Plan

If you need to rollback to v4.0:

1. Pin provider version back to v4.0:
```hcl
cloudflare = {
  source  = "cloudflare/cloudflare"
  version = "~> 4.0"
}
```

2. Use the previous version of the module (if versioned)

3. Run:
```bash
terraform init -upgrade
terraform apply
```

## Validation

After migration, verify:

1. **Worker is running:**
```bash
curl -I https://your-domain.com/ | grep X-Website-Version
```

2. **Routes are active:**
Check Cloudflare dashboard → Workers & Pages → your-worker → Routes

3. **Bindings are working:**
Check worker logs for any binding-related errors

4. **Feature flags still work:**
Test different versions via ConfigCat

## Support

If you encounter issues:

1. Check Cloudflare Provider v5.0 changelog
2. Review Terraform state for any drift
3. Verify all bindings are correctly migrated
4. Check worker logs in Cloudflare dashboard

## Additional Resources

- [Cloudflare Provider v5.0 Release Notes](https://github.com/cloudflare/terraform-provider-cloudflare/releases)
- [Cloudflare Workers Documentation](https://developers.cloudflare.com/workers/)
- [Module Documentation](modules/cloudflare-worker/README.md)

