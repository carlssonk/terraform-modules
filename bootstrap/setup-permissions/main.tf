terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {}
}

data "aws_caller_identity" "current" {}

locals {
  oidc_domain           = "token.actions.githubusercontent.com"
  github_actions_cicd_policy = "github-actions-cicd-policy"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://${local.oidc_domain}"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Name        = "github-actions-oidc-provider"
    Environment = terraform.workspace
    Purpose     = "github-actions-oidc"
    ManagedBy   = "terraform"
    Component   = "bootstrap"
  }
}

resource "aws_iam_role" "github_actions_cicd_role" {
  name = "github-actions-cicd-role"
  description = "Role for GitHub Actions CI/CD automation"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Condition = {
          StringEquals = {
            "${local.oidc_domain}:aud" : "sts.amazonaws.com"
          }
          StringLike = {
            "${local.oidc_domain}:sub" : [
              "repo:${var.organization}/${var.repository}:ref:refs/heads/main",
              "repo:${var.organization}/${var.repository}:environment:${terraform.workspace}"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Protected   = "true"
    Name        = "github-actions-cicd-role"
    Environment = terraform.workspace
    Purpose     = "cicd-terraform-and-deployments"
    ManagedBy   = "terraform"
    Component   = "bootstrap"
  }
}

resource "aws_iam_policy" "github_actions_cicd_policy" {
  name        = local.github_actions_cicd_policy
  description = "Policy for GitHub Actions CI/CD - Terraform and deployment operations"

  tags = {
    Name        = local.github_actions_cicd_policy
    Environment = terraform.workspace
    Purpose     = "cicd-permissions"
    ManagedBy   = "terraform"
    Component   = "bootstrap"
  }

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Backend management (s3)
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::terraform-state-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::terraform-state-${data.aws_caller_identity.current.account_id}/*"
        ]
      },
      # Backend management (dynamodb)
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        Resource = "arn:aws:dynamodb:${var.aws_region}:*:table/terraform-lock-table-${data.aws_caller_identity.current.account_id}"
      },
      # OpenID Connect Provider
      {
        Effect = "Allow",
        Action = ["iam:GetOpenIDConnectProvider"],
        Resource = "arn:aws:iam::*:oidc-provider/${local.oidc_domain}"
      },
      # IAM permissions (except for protected resources) 
      {
        Effect = "Allow"
        Action = ["iam:*"]
        Resource = [
          "arn:aws:iam::*:role/*",
          "arn:aws:iam::*:policy/*"
        ]
        Condition = {
          StringNotEquals = {
            "iam:ResourceTag/Protected": "true"
          }
        }
      },
      # IAM list operations
      {
        Effect = "Allow"
        Action = [
          "iam:ListPolicies",
          "iam:ListRoles",
          "iam:ListInstanceProfiles"
        ]
        Resource = "*"
      },
      # AWS Services (wildcard for development speed)
      {
        Effect = "Allow"
        Action = [
          "iam:*Tags*",
          "s3:*",
          "dynamodb:*",
          "ecs:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "logs:*",
          "ecr:*",
          "rds:*",
          "secretsmanager:*",
          "acm:*",
          "route53:*",
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_cicd_policy" {
  policy_arn = aws_iam_policy.github_actions_cicd_policy.arn
  role       = aws_iam_role.github_actions_cicd_role.name
}