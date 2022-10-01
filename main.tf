data "aws_caller_identity" "current" {}

# appending random characters to some fields that need to be globally unique
resource "random_id" "name_suffix" {
  byte_length = 4
}

#---------------------------
# VPC & Security Groups
#---------------------------
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "vault" {
  name        = "Vault server required ports"
  vpc_id      = aws_default_vpc.default.id
  description = "Security group for HashiCorp Vault"
}

resource "aws_security_group_rule" "vault_api_tcp" {
  type              = "ingress"
  description       = "Vault API/UI"
  security_group_id = aws_security_group.vault.id
  from_port         = 8200
  to_port           = 8200
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress_web" {
  type              = "egress"
  description       = "Internet access"
  security_group_id = aws_security_group.vault.id
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}


#---------------------------
# ECR
#---------------------------
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
resource "aws_ecr_repository" "vault_ecr" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = false
  }
}


#---------------------------
# KMS
#---------------------------
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key
resource "aws_kms_key" "s3_key" {
  description = "S3 SSE key"
  key_usage   = "ENCRYPT_DECRYPT"

  deletion_window_in_days = 7
  enable_key_rotation     = false
  multi_region            = false
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/s3-sse-key"
  target_key_id = aws_kms_key.s3_key.key_id
}

resource "aws_kms_key" "vault_key" {
  description = "Vault Auto Unseal key"
  key_usage   = "ENCRYPT_DECRYPT"

  deletion_window_in_days = 7
  enable_key_rotation     = false
  multi_region            = false
}

resource "aws_kms_alias" "vault_key_alias" {
  name          = "alias/vault-auto-unseal-key"
  target_key_id = aws_kms_key.vault_key.key_id
}


#---------------------------
# S3
#---------------------------
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "vault_s3_backend" {
  bucket        = "${var.s3_bucket_name}-${random_id.name_suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_sse" {
  bucket = aws_s3_bucket.vault_s3_backend.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_block_public" {
  bucket = aws_s3_bucket.vault_s3_backend.id

  # block public bucket
  block_public_acls   = true
  block_public_policy = true

  # block public objects
  ignore_public_acls = true
}

#resource "aws_s3_bucket_acl" "vault_s3_backend_acl" {
#  bucket = aws_s3_bucket.vault_s3_backend.id
#  acl    = "private"
#}
