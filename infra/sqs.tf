resource "aws_sqs_queue" "lambda_work_dlq" {
  name                       = "${var.project_name}-lambda-work-dlq"
  message_retention_seconds  = 1209600
  kms_master_key_id          = aws_kms_key.eks_secrets.id
  kms_data_key_reuse_period_seconds = 300

  tags = {
    Name = "${local.name_prefix}-lambda-work-dlq"
  }
}

resource "aws_sqs_queue" "lambda_work_queue" {
  name                       = "${var.project_name}-lambda-work-queue"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 86400
  kms_master_key_id          = aws_kms_key.eks_secrets.id
  kms_data_key_reuse_period_seconds = 300

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.lambda_work_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name = "${local.name_prefix}-lambda-work-queue"
  }
}
