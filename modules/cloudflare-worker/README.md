# Cloudflare Worker Module

This module creates and manages a Cloudflare Worker with routes attached to a zone using Cloudflare provider v5.0.

## Features

- Deploy JavaScript Workers to Cloudflare's edge network
- Attach workers to specific routes in your zone
- Support for secret bindings (API keys, tokens)
- Support for KV namespace bindings
- Support for plain text bindings (environment variables)
- Compatibility date and flags configuration
- Optional Logpush integration

## Usage

```hcl
module "my_worker" {
  source      = "../../modules/cloudflare-worker"
  account_id  = "your-cloudflare-account-id"
  zone_name   = "example.com"
  worker_name = "my-worker"

  worker_script = file("${path.module}/worker.js")

  # Compatibility settings
  compatibility_date  = "2024-01-01"
  compatibility_flags = ["nodejs_compat"]

  # Enable Logpush
  logpush = true

  routes = {
    main = {
      pattern = "example.com/*"
    }
  }

  secrets = {
    API_KEY = var.api_key
  }

  plain_text_bindings = {
    ENVIRONMENT = "production"
    BUCKET_NAME = "my-bucket"
  }

  kv_namespaces = {
    MY_KV = var.kv_namespace_id
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| account_id | Cloudflare account ID | string | - | Yes |
| zone_name | The zone name (domain) to attach the worker to | string | - | Yes |
| worker_name | Name of the Cloudflare Worker | string | - | Yes |
| worker_script | The JavaScript content of the Worker script | string | - | Yes |
| compatibility_date | Date indicating targeted support in the Workers runtime | string | "2024-01-01" | No |
| compatibility_flags | Flags that enable or disable certain features | list(string) | [] | No |
| logpush | Whether Logpush is turned on for the Worker | bool | false | No |
| routes | Map of routes to attach the worker to | map(object) | {} | No |
| secrets | Map of secret text bindings | map(string) | {} | No |
| kv_namespaces | Map of KV namespace bindings | map(string) | {} | No |
| plain_text_bindings | Map of plain text bindings | map(string) | {} | No |

## Outputs

| Name | Description |
|------|-------------|
| worker_id | ID of the Cloudflare Worker |
| worker_name | Name of the Cloudflare Worker |
| worker_etag | Hashed script content (for update detection) |
| routes | Map of created worker routes |
| zone_id | Cloudflare zone ID where the worker is attached |

## Worker Script Bindings

When writing your worker script, you can access bindings as global variables:

```javascript
// Secrets (from var.secrets)
const apiKey = MY_SECRET;

// Plain text bindings (from var.plain_text_bindings)
const bucketName = S3_BUCKET_NAME;

// KV namespaces (from var.kv_namespaces)
await MY_KV.get('key');
```

## Compatibility Settings

### Compatibility Date

The `compatibility_date` specifies which version of the Workers runtime to target. This ensures your Worker continues to work even as the runtime evolves. Format: `YYYY-MM-DD`

### Compatibility Flags

Common compatibility flags include:
- `nodejs_compat` - Enable Node.js compatibility features
- `streams_enable_constructors` - Enable stream constructors

See [Cloudflare docs](https://developers.cloudflare.com/workers/configuration/compatibility-dates/) for more information.

## Route Patterns

Route patterns determine where your worker runs. Examples:

- `example.com/*` - All paths on example.com
- `*.example.com/*` - All subdomains
- `example.com/api/*` - Only /api paths

## Logpush

When enabled, Worker logs are pushed to configured destinations (e.g., S3, R2, or third-party services). Configure destinations in the Cloudflare dashboard.

## Provider Version

This module requires Cloudflare provider version 5.0 or later:

```hcl
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}
```

## Notes

- Workers require a Cloudflare account with Workers enabled
- Free tier allows up to 100,000 requests per day
- Workers run on Cloudflare's V8 isolate runtime
- Secrets are write-only and cannot be read back from Terraform
- The module uses `cloudflare_workers_script` resource (v5.0 syntax)

