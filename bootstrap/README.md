## Bootstrap user IAM policy

Replace `AWS_ACCOUNT_ID` with your AWS Account ID (12-digit number)
Replace `AWS_REGION` with the AWS region

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
                "s3:PutObject",
                "s3:PutBucketTagging",
                "s3:PutBucketVersioning",
                "s3:PutEncryptionConfiguration",
                "s3:PutBucketPublicAccessBlock"
            ],
            "Resource": [
                "arn:aws:s3:::AWS_ACCOUNT_ID-terraform-state",
                "arn:aws:s3:::AWS_ACCOUNT_ID-terraform-state/*"
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
                "dynamodb:ListTagsOfResource",
                "dynamodb:TagResource",
                "dynamodb:UpdateContinuousBackups"
            ],
            "Resource": "arn:aws:dynamodb:AWS_REGION:AWS_ACCOUNT_ID:table/AWS_ACCOUNT_ID-terraform-lock-table"
        },
        {
            "Sid": "IAMOpenIdConnectProviderAndGithubActionsCicdRole",
            "Effect": "Allow",
            "Action": [
                "iam:CreateOpenIDConnectProvider",
                "iam:GetOpenIDConnectProvider",
                "iam:TagOpenIDConnectProvider",
                "iam:CreateRole",
                "iam:GetRole",
                "iam:TagRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:ListAttachedRolePolicies",
                "iam:ListRolePolicies",
                "iam:UpdateAssumeRolePolicy"
            ],
            "Resource": [
                "arn:aws:iam::*:oidc-provider/token.actions.githubusercontent.com",
                "arn:aws:iam::*:role/github-actions-cicd-role"
            ]
        },
        {
            "Sid": "IAMBasePolicyForGithubActionsCicdRole",
            "Effect": "Allow",
            "Action": [
                "iam:CreatePolicy",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:ListPolicyVersions",
                "iam:CreatePolicyVersion",
                "iam:TagPolicy"
            ],
            "Resource": "arn:aws:iam::*:policy/github-actions-cicd-policy"
        }
    ]
}
```