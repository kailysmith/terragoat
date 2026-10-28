resource "aws_lambda_function" "main" {
  function_name                  = "${local.name_prefix}-function"
  role                           = aws_iam_role.lambda_execution.arn
  handler                        = "index.handler"
  runtime                        = var.lambda_runtime
  timeout                        = 30
  memory_size                    = 256
  reserved_concurrent_executions = var.lambda_reserved_concurrency

  filename         = "${path.module}/lambda_placeholder.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_placeholder.zip")

  vpc_config {
    subnet_ids         = var.private_app_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      RDS_SECRET_ARN        = aws_secretsmanager_secret.rds_master.arn
      LAMBDA_API_SECRET_ARN = aws_secretsmanager_secret.lambda_api_keys.arn
      AWS_REGION_NAME       = var.aws_region
    }
  }

  tracing_config {
    mode = "Active"
  }

  tags = {
    Name = "${local.name_prefix}-function"
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.lambda_work_queue.arn
  function_name    = aws_lambda_function.main.arn
  batch_size       = 10
  enabled          = true
}
