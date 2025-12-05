# Example: Using the Cloudflare CDN Website with Worker

This example shows how to deploy a website with feature-flag based version routing using Cloudflare Provider v5.0.

## Prerequisites

1. AWS credentials configured
2. Cloudflare API token with appropriate permissions
3. ConfigCat account and API key (optional)
4. Cloudflare account ID

## Terraform Configuration

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "configcat_api_key" {
  description = "ConfigCat SDK key"
  type        = string
  sensitive   = true
}

module "website" {
  source = "../../compositions/cloudflare-cdn-website"

  root_domain = "example.com"
  subdomain   = "www"

  # Enable Cloudflare Worker for feature-flag routing
  enable_worker         = true
  cloudflare_account_id = var.cloudflare_account_id

  # ConfigCat API key for feature flags
  worker_secrets = {
    CONFIGCAT_API_KEY = var.configcat_api_key
  }

  # Optional: Worker runtime compatibility settings
  worker_compatibility_date  = "2024-01-01"
  worker_compatibility_flags = ["nodejs_compat"]
  
  # Optional: Enable Logpush
  worker_logpush = true

  # Optional: Set default hash for fallback
  worker_plain_text_bindings = {
    DEFAULT_HASH = "production-v1"
  }

  tags = {
    Environment = "production"
    Project     = "my-website"
    ManagedBy   = "terraform"
  }
}

output "website_url" {
  value = module.website.subdomain_website_url
}

output "bucket_name" {
  value = module.website.subdomain_bucket_name
}

output "worker_name" {
  value = module.website.worker_name
}
```

## Deploy Website Versions to S3

After applying the Terraform configuration, deploy your website versions:

```bash
# Deploy version 1
aws s3 sync ./build s3://www.example.com/v1.0.0/ --delete

# Deploy version 2
aws s3 sync ./build s3://www.example.com/v2.0.0/ --delete

# Deploy staging version
aws s3 sync ./build s3://www.example.com/staging/ --delete
```

## Configure Feature Flags in ConfigCat

1. Log into ConfigCat dashboard
2. Navigate to your feature flags
3. Create or edit the `website_hash` flag
4. Set up targeting rules:

```
Rule 1: Beta Users
  IF User.Email CONTAINS @beta-testers.com
  THEN serve: v2.0.0

Rule 2: Staff
  IF User.Email CONTAINS @example.com
  THEN serve: staging

Default:
  serve: v1.0.0
```

## Testing

Test the worker is functioning:

```bash
# Should serve v1.0.0 (default)
curl -I https://www.example.com/

# Check which version is served
curl -I https://www.example.com/ | grep X-Website-Version
```

## Gradual Rollout Example

Use ConfigCat percentage rollouts:

```
Rule 1: Gradual Rollout
  IF User.Identifier IN 10%
  THEN serve: v2.0.0

Default:
  serve: v1.0.0
```

Then gradually increase the percentage:
- Day 1: 10% get v2.0.0
- Day 2: 25% get v2.0.0
- Day 3: 50% get v2.0.0
- Day 4: 100% get v2.0.0

## Instant Rollback

If v2.0.0 has issues, simply change the feature flag in ConfigCat:

1. Open ConfigCat dashboard
2. Set `website_hash` default value to `v1.0.0`
3. Save

All users will immediately see v1.0.0 without redeploying or changing Terraform.

## Cost Considerations

- Cloudflare Workers: 100,000 requests/day free, then $0.50 per million requests
- S3: Standard storage and transfer costs
- ConfigCat: Free tier includes 1000 config fetches/month

## Security Notes

- Store sensitive variables in a secure location (e.g., AWS Secrets Manager, Terraform Cloud)
- Use Cloudflare API tokens with minimal required permissions
- Regularly rotate ConfigCat API keys
- Consider adding WAF rules to protect the worker endpoint

