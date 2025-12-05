## Using Terraform Modules in your own repository

This guide shows you how to setup and use Terraform Modules provided by this project, in your own project, along with GHA integration.

> See [app-template](https://github.com/carlssonk/app-template) for a complete example

### Repository & AWS setup
1. If using `ad-m/github-push-action@master` in a workflow. Enable `Allow GitHub Actions to create and approve pull requests` in Github Actions -> General
2. Add `AWS_REGION` to repository variables
3. Create a new AWS account for the environment you want to bootstrap. (or use an existing account; you can reset it with [aws-nuke](https://github.com/ekristen/aws-nuke))
4. Create a new IAM bootstrap user and add [this](bootstrap/README.md) as inline policy (replace `AWS_ACCOUNT_ID` and `AWS_REGION` placeholders)
5. Create secret access key from the bootstrap user and save the access key and access secret for the next step
6. Set up a new repository environment in Github (Settings -> Environments) and add `BOOTSTRAP_AWS_ACCESS_KEY` and `BOOTSTRAP_AWS_ACCESS_SECRET` as secrets for the environment
7. Done

### Set up Cloudflare
1. Create a Cloudflare account
2. Add your domain name and make sure DNS records are empty and you have added the cloudflare nameservers to your domain register
3. Retrieve your API token at your [Cloudflare dashboard](https://dash.cloudflare.com/profile/api-tokens) and add `CLOUDFLARE_API_TOKEN` to your environment secret.
4. (Optional) If using Cloudflare Workers, retrieve your Account ID from the Cloudflare dashboard and add `CLOUDFLARE_ACCOUNT_ID` to your environment variables
5. **Note:** Cloudflare Workers module requires Cloudflare Provider v5.0 or later. See [MIGRATION_V5.md](MIGRATION_V5.md) if upgrading from v4.0.
6. Done

## Available Modules

### Infrastructure Modules

#### AWS Modules
- **[s3](modules/s3/)** - S3 bucket with website hosting and bucket policies
- **[dynamodb](modules/dynamodb/)** - DynamoDB table configuration
- **[cloudwatch](modules/cloudwatch/)** - CloudWatch log groups and alarms

#### Cloudflare Modules
- **[cloudflare-zone](modules/cloudflare-zone/)** - Cloudflare zone settings management
- **[cloudflare-dns-record](modules/cloudflare-dns-record/)** - DNS record management
- **[cloudflare-worker](modules/cloudflare-worker/)** - Cloudflare Workers deployment with routes and bindings

### Compositions

#### [cloudflare-cdn-website](compositions/cloudflare-cdn-website/)
Complete CDN-backed website using S3 and Cloudflare. Supports:
- Static website hosting on S3
- Cloudflare DNS and CDN
- Optional Cloudflare Worker for feature-flag based version routing
- ConfigCat integration for dynamic version selection

**Use cases:**
- Static websites with CDN
- Feature-flag based deployments
- A/B testing different versions
- Gradual rollouts with instant rollback capability

See the [composition README](compositions/cloudflare-cdn-website/README.md) for detailed usage.

## Cloudflare Workers

The `cloudflare-worker` module enables advanced edge computing capabilities:

- **Feature-flag routing**: Serve different website versions based on ConfigCat feature flags
- **Dynamic content**: Process requests at the edge before reaching origin
- **Custom logic**: Implement authentication, redirects, request/response modification
- **KV storage**: Use Cloudflare's key-value storage at the edge
- **Secrets management**: Securely store API keys and tokens

Example use case: Deploy multiple versions of your website to S3 under different paths (e.g., `/v1/`, `/v2/`, `/staging/`), then use a Worker with ConfigCat to dynamically route users to the appropriate version based on feature flags, without changing DNS or redeploying infrastructure.
