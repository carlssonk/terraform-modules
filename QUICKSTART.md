# Quick Start: Cloudflare Worker for Feature-Flag Routing

**Requirements:**
- Cloudflare Provider v5.0 or later
- AWS Provider for S3 resources
- ConfigCat account (optional, for feature flags)

## 1. Enable Worker in Your Composition

```hcl
module "website" {
  source = "../../compositions/cloudflare-cdn-website"

  root_domain = "example.com"
  subdomain   = "www"

  enable_worker         = true
  cloudflare_account_id = "your-account-id"

  worker_secrets = {
    CONFIGCAT_API_KEY = "your-configcat-sdk-key"
  }
}
```

## 2. Deploy Versioned Content to S3

```bash
# Deploy version 1
aws s3 sync ./build s3://www.example.com/v1.0.0/

# Deploy version 2  
aws s3 sync ./build s3://www.example.com/v2.0.0/
```

## 3. Configure Feature Flag in ConfigCat

1. Go to ConfigCat dashboard
2. Create flag: `website_hash` (type: String)
3. Set default value: `v1.0.0`
4. Add targeting rules as needed

## 4. Test

```bash
# Check which version is served
curl -I https://www.example.com/ | grep X-Website-Version
```

## Common Patterns

### Gradual Rollout
```
Rule: 10% of users
  → serve: v2.0.0
Default:
  → serve: v1.0.0
```

### Beta Testing
```
Rule: User.Email contains @beta.com
  → serve: v2.0.0
Default:
  → serve: v1.0.0
```

### Geographic Targeting
```
Rule: User.Country = "US"
  → serve: v2.0.0
Default:
  → serve: v1.0.0
```

### Staff Preview
```
Rule: User.Email contains @example.com
  → serve: staging
Default:
  → serve: v1.0.0
```

## Instant Rollback

If v2.0.0 has issues:
1. Open ConfigCat dashboard
2. Change default to `v1.0.0`
3. Save

All users immediately see v1.0.0 (no deployment needed).

## Custom Worker Script

To use a different logic:

```hcl
module "website" {
  # ... other config ...
  
  worker_script = file("${path.module}/my-custom-worker.js")
}
```

## Troubleshooting

**Worker not running?**
- Check Cloudflare account ID is correct
- Verify Worker is enabled in Cloudflare dashboard
- Check worker routes are configured

**Wrong version served?**
- Verify ConfigCat API key is correct
- Check feature flag name matches `website_hash`
- Look at `X-Website-Version` response header

**500 errors?**
- Check Cloudflare Workers logs in dashboard
- Verify S3 bucket has correct content paths
- Test S3 URLs directly

## Resources

- [Module README](modules/cloudflare-worker/README.md)
- [Composition README](compositions/cloudflare-cdn-website/README.md)
- [Detailed Example](compositions/cloudflare-cdn-website/EXAMPLE.md)
- [ConfigCat Docs](https://configcat.com/docs/)
- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)

