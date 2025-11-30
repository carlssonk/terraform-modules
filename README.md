## Using Terraform Modules in your own repository

This guide shows you how to setup and use Terraform Modules provided by this project, in your own project, along with GHA integration.

> See [app-template](https://github.com/carlssonk/app-template) for a complete example

### Repository & AWS setup
1. If using `ad-m/github-push-action@master` in a workflow. Enable `Allow GitHub Actions to create and approve pull requests` in Github Actions -> General
2. Add `AWS_REGION` and `ORGANIZATION` to repository variables
3. Create a new AWS account for the environment you want to bootstrap. (or use an existing account; you can reset it with [aws-nuke](https://github.com/ekristen/aws-nuke))
4. Create a new IAM bootstrap user and add [this](bootstrap/README.md) as inline policy
5. Create secret access key from the bootstrap user and save the access key and access secret for the next step
6. Set up a new repository environment in Github (Settings -> Environments) and add `BOOTSTRAP_AWS_ACCESS_KEY` and `BOOTSTRAP_AWS_ACCESS_SECRET` as secrets for the environment
7. Done

### Set up Cloudflare
1. Create a Cloudflare account
2. Add your domain name and make sure DNS records are empty and you have added the cloudflare nameservers to your domain register
3. Retrieve your API token at your [Cloudflare dashboard](https://dash.cloudflare.com/profile/api-tokens) and add `CLOUDFLARE_API_TOKEN` to your environment secret.
4. Done
