locals {
  name_prefix = substr("${var.project_name}-${var.environment}", 0, 20)
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ── Random passwords ─────────────────────────────────────────────────────────
resource "random_password" "aurora_master" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "neptune_master" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "opensearch_admin" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ── Random suffix for S3 bucket names ────────────────────────────────────────
resource "random_string" "s3_suffix" {
  length  = 8
  special = false
  upper   = false
}
