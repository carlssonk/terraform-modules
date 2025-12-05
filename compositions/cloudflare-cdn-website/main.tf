locals {
  domain_name = "${var.subdomain}.${var.root_domain}"
}

module "subdomain_bucket" {
  source      = "../../modules/s3"
  bucket_name = local.domain_name
  website_config = {
    enabled        = true
    index_document = var.index_document
  }
  bucket_policy = {
    name        = "cloudflare"
    permissions = ["s3:GetObject"]
  }

  force_destroy               = var.force_destroy
  tags                        = var.tags
  block_public_acls           = false
  block_public_policy         = false
  ignore_public_acls          = false
  restrict_public_buckets     = false
}

module "root_bucket" {
  count       = var.subdomain == "www" ? 1 : 0
  source      = "../../modules/s3"
  bucket_name = var.root_domain
  website_config = {
    redirect_to       = local.domain_name
    redirect_protocol = "https"
  }

  force_destroy = var.force_destroy
  tags          = var.tags

  depends_on = [module.subdomain_bucket]
}

module "cloudflare_dns_record" {
  source      = "../../modules/cloudflare-dns-record"
  root_domain = var.root_domain
  dns_records = merge(
    {
      "${var.subdomain}_subdomain_record" = {
        name  = var.subdomain
        value = module.subdomain_bucket.website_endpoint
      }
    },
    var.subdomain == "www" ? {
      "${var.root_domain}_root_record" = {
        name  = "@"
        value = module.root_bucket[0].website_endpoint
      }
    } : {}
  )
}

# Cloudflare Worker for feature-flag based routing
module "cloudflare_worker" {
  count = var.enable_worker ? 1 : 0

  source      = "../../modules/cloudflare-worker"
  account_id  = var.cloudflare_account_id
  zone_name   = var.root_domain
  worker_name = var.worker_name != null ? var.worker_name : "${replace(local.domain_name, ".", "-")}-worker"

  worker_script = var.worker_script != null ? var.worker_script : file("${path.module}/worker.js")

  # Worker runtime configuration (Cloudflare Provider v5.0)
  compatibility_date  = var.worker_compatibility_date
  compatibility_flags = var.worker_compatibility_flags
  logpush             = var.worker_logpush

  routes = {
    main = {
      pattern = "${local.domain_name}/*"
    }
  }

  secrets = var.worker_secrets

  plain_text_bindings = merge(
    {
      S3_BUCKET_NAME = module.subdomain_bucket.bucket_id
    },
    var.worker_plain_text_bindings
  )

  kv_namespaces = var.worker_kv_namespaces
}