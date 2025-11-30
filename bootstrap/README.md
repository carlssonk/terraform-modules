## Bootstrap user IAM policy

Replace `ENVIRONMENT` with your environment/workspace (same as branch name and repo environment)

Replace `AWS_REGION` with the AWS region (same as AWS_REGION that you added in repository variables)

Replace `ORGANIZATION` with the repository/organization name (same as ORGANIZATION that you added in repository variables)

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CreateS3BucketForTerraformBackend",
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:ListBucket",
                "s3:Get*",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::ORGANIZATION-terraform-state-bucket-ENVIRONMENT",
                "arn:aws:s3:::ORGANIZATION-terraform-state-bucket-ENVIRONMENT/*"
            ]
        },
        {
            "Sid": "CreateDynamoDBTableForTerraformBackend",
            "Effect": "Allow",
            "Action": [
                "dynamodb:CreateTable",
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:DescribeTable",
                "dynamodb:DescribeContinuousBackups",
                "dynamodb:DescribeTimeToLive",
                "dynamodb:ListTagsOfResource"
            ],
            "Resource": "arn:aws:dynamodb:AWS_REGION:*:table/ORGANIZATION-terraform-lock-table-ENVIRONMENT"
        },
        {
            "Sid": "IAMOpenIdConnectProviderAndTerraformExecutionRole",
            "Effect": "Allow",
            "Action": [
                "iam:CreateOpenIDConnectProvider",
                "iam:DeleteOpenIDConnectProvider",
                "iam:GetOpenIDConnectProvider",
                "iam:UpdateOpenIDConnectProviderThumbprint",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:GetRole",
                "iam:UpdateRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:ListAttachedRolePolicies",
                "iam:ListRolePolicies",
                "iam:UpdateAssumeRolePolicy"
            ],
            "Resource": [
                "arn:aws:iam::*:oidc-provider/token.actions.githubusercontent.com",
                "arn:aws:iam::*:role/terraform-execution-role"
            ]
        },
        {
            "Sid": "IAMBasePolicyForTerraformExecutionRole",
            "Effect": "Allow",
            "Action": [
                "iam:CreatePolicy",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:DeletePolicy",
                "iam:ListPolicyVersions",
                "iam:CreatePolicyVersion"
            ],
            "Resource": "arn:aws:iam::*:policy/terraform-base-policy"
        },
        {
            "Sid": "IAMPassRole",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::*:role/terraform-execution-role",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "sts.amazonaws.com"
                }
            }
        }
    ]
}
```