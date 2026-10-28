# ── RDS Master Credentials ────────────────────────────────────────────────────
resource "aws_secretsmanager_secret" "rds_master" {
  name                    = "${var.project_name}/rds-master-credentials"
  description             = "Aurora PostgreSQL master credentials"
  kms_key_id              = aws_kms_key.secrets.arn
  recovery_window_in_days = 7

  tags = {
    Name = "${local.name_prefix}-rds-master-creds"
  }
}

resource "aws_secretsmanager_secret_version" "rds_master" {
  secret_id = aws_secretsmanager_secret.rds_master.id
  secret_string = jsonencode({
    username = "aurora_admin"
    password = random_password.aurora_master.result
  })
}

resource "aws_secretsmanager_secret_rotation" "rds_master" {
  secret_id           = aws_secretsmanager_secret.rds_master.id
  rotation_lambda_arn = aws_lambda_function.secrets_rotation.arn

  rotation_rules {
    automatically_after_days = var.secrets_rotation_days
  }
}

# ── Neptune Credentials ───────────────────────────────────────────────────────
resource "aws_secretsmanager_secret" "neptune" {
  name                    = "${var.project_name}/neptune-credentials"
  description             = "Neptune graph database credentials"
  kms_key_id              = aws_kms_key.secrets.arn
  recovery_window_in_days = 7

  tags = {
    Name = "${local.name_prefix}-neptune-creds"
  }
}

resource "aws_secretsmanager_secret_version" "neptune" {
  secret_id = aws_secretsmanager_secret.neptune.id
  secret_string = jsonencode({
    username = "neptune_admin"
    password = random_password.neptune_master.result
  })
}

resource "aws_secretsmanager_secret_rotation" "neptune" {
  secret_id           = aws_secretsmanager_secret.neptune.id
  rotation_lambda_arn = aws_lambda_function.secrets_rotation.arn

  rotation_rules {
    automatically_after_days = var.secrets_rotation_days
  }
}

# ── Lambda API Keys ───────────────────────────────────────────────────────────
resource "aws_secretsmanager_secret" "lambda_api_keys" {
  name                    = "${var.project_name}/lambda-api-keys"
  description             = "API keys consumed by Lambda functions"
  kms_key_id              = aws_kms_key.secrets.arn
  recovery_window_in_days = 7

  tags = {
    Name = "${local.name_prefix}-lambda-api-keys"
  }
}

resource "aws_secretsmanager_secret_version" "lambda_api_keys" {
  secret_id = aws_secretsmanager_secret.lambda_api_keys.id
  secret_string = jsonencode({
    api_key = "REPLACE_AT_DEPLOY_TIME"
  })
}

resource "aws_secretsmanager_secret_rotation" "lambda_api_keys" {
  secret_id           = aws_secretsmanager_secret.lambda_api_keys.id
  rotation_lambda_arn = aws_lambda_function.secrets_rotation.arn

  rotation_rules {
    automatically_after_days = var.secrets_rotation_days
  }
}

# ── Secrets Rotation Lambda ───────────────────────────────────────────────────
resource "aws_lambda_function" "secrets_rotation" {
  function_name = "${local.name_prefix}-secrets-rotation"
  role          = aws_iam_role.secrets_rotation_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30

  filename         = "${path.module}/rotation_placeholder.zip"
  source_code_hash = filebase64sha256("${path.module}/rotation_placeholder.zip")

  vpc_config {
    subnet_ids         = var.private_app_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${var.aws_region}.amazonaws.com"
    }
  }

  tracing_config {
    mode = "Active"
  }

  tags = {
    Name = "${local.name_prefix}-secrets-rotation"
  }
}

resource "aws_lambda_permission" "secrets_rotation_rds" {
  statement_id  = "AllowSecretsManagerRDS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.secrets_rotation.function_name
  principal     = "secretsmanager.amazonaws.com"
  source_arn    = aws_secretsmanager_secret.rds_master.arn
}

resource "aws_lambda_permission" "secrets_rotation_neptune" {
  statement_id  = "AllowSecretsManagerNeptune"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.secrets_rotation.function_name
  principal     = "secretsmanager.amazonaws.com"
  source_arn    = aws_secretsmanager_secret.neptune.arn
}

resource "aws_lambda_permission" "secrets_rotation_lambda_api" {
  statement_id  = "AllowSecretsManagerLambdaApi"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.secrets_rotation.function_name
  principal     = "secretsmanager.amazonaws.com"
  source_arn    = aws_secretsmanager_secret.lambda_api_keys.arn
}
