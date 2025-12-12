locals {
  domain_name = "${var.subdomain}.${var.root_domain}"
  tags = merge(
    {
      Environment = terraform.workspace
      ManagedBy   = "terraform"
    },
    var.tags
  )
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

  force_destroy           = var.force_destroy
  tags                    = local.tags
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
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
  tags          = local.tags

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
