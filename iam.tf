resource "aws_iam_user" "vault-user" {
  name = "vault-ecs-user"

  force_destroy = true
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
# https://docs.aws.amazon.com/AmazonS3/latest/API/API_Operations_Amazon_Simple_Storage_Service.html
# https://docs.aws.amazon.com/kms/latest/APIReference/API_Operations.html
resource "aws_iam_policy" "vault-user-policy" {
  name        = "vault-ecs-policy"
  description = "ECS Vault user IAM policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:DeleteObjects",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:ListKeys",
          "kms:DescribeKey"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment
resource "aws_iam_user_policy_attachment" "vault-user-policy-attach" {
  user       = aws_iam_user.vault-user.name
  policy_arn = aws_iam_policy.vault-user-policy.arn
}

# WARNING: this is not secure as keys are stored in plain text inside .tfstate file
resource "aws_iam_access_key" "vault-user" {
  user = aws_iam_user.vault-user.name
}
