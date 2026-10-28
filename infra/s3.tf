locals {
  s3_suffix = random_string.s3_suffix.result
}

# ── Logs Bucket (created first — used by other buckets for access logging) ────
resource "aws_s3_bucket" "logs" {
  bucket = "${var.project_name}-logs-${local.s3_suffix}"

  tags = {
    Name = "${local.name_prefix}-logs"
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "logs_alb" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ALBAccessLogs"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::127311923021:root"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs.arn}/alb-access-logs/*"
      }
    ]
  })
}

# ── Data Bucket ───────────────────────────────────────────────────────────────
resource "aws_s3_bucket" "data" {
  bucket = "${var.project_name}-data-${local.s3_suffix}"

  tags = {
    Name = "${local.name_prefix}-data"
  }
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "data" {
  bucket        = aws_s3_bucket.data.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/data/"
}

# ── Financials Bucket ─────────────────────────────────────────────────────────
resource "aws_s3_bucket" "financials" {
  bucket = "${var.project_name}-financials-${local.s3_suffix}"

  tags = {
    Name = "${local.name_prefix}-financials"
  }
}

resource "aws_s3_bucket_versioning" "financials" {
  bucket = aws_s3_bucket.financials.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "financials" {
  bucket = aws_s3_bucket.financials.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "financials" {
  bucket                  = aws_s3_bucket.financials.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "financials" {
  bucket        = aws_s3_bucket.financials.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/financials/"
}

# ── Operations Bucket ─────────────────────────────────────────────────────────
resource "aws_s3_bucket" "operations" {
  bucket = "${var.project_name}-operations-${local.s3_suffix}"

  tags = {
    Name = "${local.name_prefix}-operations"
  }
}

resource "aws_s3_bucket_versioning" "operations" {
  bucket = aws_s3_bucket.operations.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "operations" {
  bucket = aws_s3_bucket.operations.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "operations" {
  bucket                  = aws_s3_bucket.operations.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "operations" {
  bucket        = aws_s3_bucket.operations.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/operations/"
}

# ── Data Science Bucket ───────────────────────────────────────────────────────
resource "aws_s3_bucket" "data_science" {
  bucket = "${var.project_name}-datascience-${local.s3_suffix}"

  tags = {
    Name = "${local.name_prefix}-data-science"
  }
}

resource "aws_s3_bucket_versioning" "data_science" {
  bucket = aws_s3_bucket.data_science.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_science" {
  bucket = aws_s3_bucket.data_science.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "data_science" {
  bucket                  = aws_s3_bucket.data_science.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "data_science" {
  bucket        = aws_s3_bucket.data_science.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/data-science/"
}
