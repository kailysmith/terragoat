# ── RDS KMS Key ───────────────────────────────────────────────────────────────
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS Aurora and Neptune encryption"
  deletion_window_in_days = var.kms_deletion_window_days
  enable_key_rotation     = true

  tags = {
    Name = "${local.name_prefix}-rds-key"
  }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.project_name}-rds-key"
  target_key_id = aws_kms_key.rds.key_id
}

# ── S3 KMS Key ────────────────────────────────────────────────────────────────
resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = var.kms_deletion_window_days
  enable_key_rotation     = true

  tags = {
    Name = "${local.name_prefix}-s3-key"
  }
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.project_name}-s3-key"
  target_key_id = aws_kms_key.s3.key_id
}

# ── EKS Secrets KMS Key ───────────────────────────────────────────────────────
resource "aws_kms_key" "eks_secrets" {
  description             = "KMS key for EKS secrets encryption"
  deletion_window_in_days = var.kms_deletion_window_days
  enable_key_rotation     = true

  tags = {
    Name = "${local.name_prefix}-eks-secrets-key"
  }
}

resource "aws_kms_alias" "eks_secrets" {
  name          = "alias/${var.project_name}-eks-secrets-key"
  target_key_id = aws_kms_key.eks_secrets.key_id
}

# ── CloudWatch Logs KMS Key ───────────────────────────────────────────────────
resource "aws_kms_key" "logs" {
  description             = "KMS key for CloudWatch Logs encryption"
  deletion_window_in_days = var.kms_deletion_window_days
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-logs-key"
  }
}

resource "aws_kms_alias" "logs" {
  name          = "alias/${var.project_name}-logs-key"
  target_key_id = aws_kms_key.logs.key_id
}

# ── Secrets Manager KMS Key ───────────────────────────────────────────────────
resource "aws_kms_key" "secrets" {
  description             = "KMS key for Secrets Manager secrets"
  deletion_window_in_days = var.kms_deletion_window_days
  enable_key_rotation     = true

  tags = {
    Name = "${local.name_prefix}-secrets-key"
  }
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.project_name}-secrets-key"
  target_key_id = aws_kms_key.secrets.key_id
}
