# Cloudflare CDN Website Composition

This composition creates a complete CDN-backed website using S3 for storage and Cloudflare for DNS and CDN. Optionally, it can deploy a Cloudflare Worker for advanced routing logic like feature-flag based versioning.

**Requirements:**
- Cloudflare Provider v5.0 or later
- AWS Provider for S3 resources

## Features

- S3 bucket configured for static website hosting
- Cloudflare DNS records (CNAME pointing to S3)
- Optional root domain redirect (when subdomain is "www")
- Optional Cloudflare Worker for dynamic routing
- Feature-flag based version routing via ConfigCat
- Compatibility date and flags configuration for Workers

## Basic Usage (Without Worker)

```hcl
module "website" {
  source = "../../compositions/cloudflare-cdn-website"

  root_domain = "example.com"
  subdomain   = "www"

  tags = {
    Environment = "production"
    Project     = "my-website"
  }
}
```

## Usage With Cloudflare Worker (Feature-Flag Routing)

```hcl
module "website" {
  source = "../../compositions/cloudflare-cdn-website"

  root_domain = "example.com"
  subdomain   = "www"

  # Enable the Cloudflare Worker
  enable_worker         = true
  cloudflare_account_id = "your-cloudflare-account-id"

  # Provide ConfigCat API key as a secret
  worker_secrets = {
    CONFIGCAT_API_KEY = var.configcat_api_key
  }

  # Optional: Provide custom worker script
  # worker_script = file("${path.module}/custom-worker.js")

  # Optional: Additional environment variables
  worker_plain_text_bindings = {
    DEFAULT_HASH = "abc123def"
  }

  tags = {
    Environment = "production"
    Project     = "my-website"
  }
}
```

## How the Worker Works

When enabled, the Cloudflare Worker intercepts requests to your website and:

1. Evaluates a ConfigCat feature flag named `website_hash`
2. Uses the flag value to determine which version of your website to serve
3. Fetches the content from S3 with a version prefix: `/{hash}/path/to/file.html`
4. Returns the content to the user

This allows you to:
- Deploy multiple versions of your website to S3 under different hash prefixes
- Use ConfigCat to control which version users see
- Perform gradual rollouts, A/B testing, or instant rollbacks
- Target specific users or segments with different versions

## S3 Structure for Versioned Content

With the worker enabled, organize your S3 content like this:

```
s3://www.example.com/
  ├── abc123def/           # Version 1
  │   ├── index.html
  │   ├── styles.css
  │   └── app.js
  ├── xyz789ghi/           # Version 2
  │   ├── index.html
  │   ├── styles.css
  │   └── app.js
  └── default/             # Fallback version
      ├── index.html
      └── ...
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| root_domain | The root domain name | string | - | Yes |
| subdomain | The subdomain to create | string | - | Yes |
| index_document | The index document for the website | string | "index.html" | No |
| force_destroy | Allow destruction of non-empty S3 buckets | bool | false | No |
| tags | A map of tags to assign to all resources | map(string) | {} | No |
| enable_worker | Enable Cloudflare Worker for feature-flag routing | bool | false | No |
| cloudflare_account_id | Cloudflare account ID | string | null | No* |
| worker_name | Name of the Cloudflare Worker | string | null | No |
| worker_script | Custom worker script content | string | null | No |
| worker_compatibility_date | Compatibility date for worker runtime (YYYY-MM-DD) | string | "2024-01-01" | No |
| worker_compatibility_flags | Compatibility flags for worker runtime | list(string) | [] | No |
| worker_logpush | Enable Logpush for the worker | bool | false | No |
| worker_secrets | Secret bindings for the worker | map(string) | {} | No |
| worker_plain_text_bindings | Plain text bindings for the worker | map(string) | {} | No |
| worker_kv_namespaces | KV namespace bindings for the worker | map(string) | {} | No |

*Required if `enable_worker` is true

## Outputs

| Name | Description |
|------|-------------|
| subdomain_bucket_name | Name of the subdomain S3 bucket |
| subdomain_bucket_arn | ARN of the subdomain S3 bucket |
| subdomain_website_endpoint | Website endpoint for the subdomain bucket |
| subdomain_website_url | Full website URL for the subdomain |
| root_bucket_name | Name of the root domain S3 bucket (if subdomain is 'www') |
| root_bucket_arn | ARN of the root domain S3 bucket (if subdomain is 'www') |
| root_website_endpoint | Website endpoint for the root bucket (if subdomain is 'www') |
| cloudflare_dns_records | Map of created DNS records |
| domain_name | Full domain name (subdomain.root_domain) |
| worker_id | ID of the Cloudflare Worker (if enabled) |
| worker_name | Name of the Cloudflare Worker (if enabled) |
| worker_routes | Map of worker routes (if enabled) |

## ConfigCat Setup

1. Create a ConfigCat account at https://configcat.com
2. Create a new feature flag named `website_hash` with type "String"
3. Set the default value to your default version hash
4. Create targeting rules to serve different versions to different users
5. Pass your ConfigCat SDK key as `worker_secrets.CONFIGCAT_API_KEY`

## Customizing the Worker

The default worker script is located at `worker.js` in this directory. You can:

1. Modify the default `worker.js` file
2. Provide a custom script via the `worker_script` variable
3. Extend the worker with additional functionality like:
   - Custom headers
   - Request/response logging
   - Bot detection
   - Geographic routing
   - Cache control

## Example: Custom Worker Script

```javascript
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  // Your custom logic here
  const hash = await getVersionHash(request);
  const url = new URL(request.url);
  
  url.hostname = `${S3_BUCKET_NAME}.s3.amazonaws.com`;
  url.pathname = `/${hash}${url.pathname}`;
  
  return fetch(url);
}

async function getVersionHash(request) {
  // Custom version selection logic
  // Could be based on cookies, headers, geo location, etc.
  return DEFAULT_HASH;
}
```

## Notes

- The worker runs on Cloudflare's edge network, closer to your users
- Worker requests count towards your Cloudflare Workers quota
- The free tier includes 100,000 requests per day
- Secrets (like API keys) are write-only and encrypted at rest
- The worker adds an `X-Website-Version` header to responses indicating which version was served

