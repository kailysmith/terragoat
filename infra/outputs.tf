# ── EKS ───────────────────────────────────────────────────────────────────────
output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_certificate_authority" {
  description = "Base64-encoded certificate authority data for the EKS cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

# ── ECR ───────────────────────────────────────────────────────────────────────
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.main.repository_url
}

# ── Lambda ────────────────────────────────────────────────────────────────────
output "lambda_function_arn" {
  description = "ARN of the main Lambda function"
  value       = aws_lambda_function.main.arn
}

# ── RDS Aurora ────────────────────────────────────────────────────────────────
output "aurora_cluster_endpoint" {
  description = "Writer endpoint for the Aurora PostgreSQL cluster"
  value       = aws_rds_cluster.aurora.endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "Reader endpoint for the Aurora PostgreSQL cluster"
  value       = aws_rds_cluster.aurora.reader_endpoint
}

output "aurora_secret_arn" {
  description = "ARN of the Secrets Manager secret holding Aurora credentials"
  value       = aws_secretsmanager_secret.rds_master.arn
}

# ── Neptune ───────────────────────────────────────────────────────────────────
output "neptune_cluster_endpoint" {
  description = "Writer endpoint for the Neptune cluster"
  value       = aws_neptune_cluster.main.endpoint
}

output "neptune_cluster_reader_endpoint" {
  description = "Reader endpoint for the Neptune cluster"
  value       = aws_neptune_cluster.main.reader_endpoint
}

# ── OpenSearch ────────────────────────────────────────────────────────────────
output "opensearch_domain_endpoint" {
  description = "Endpoint for the OpenSearch domain"
  value       = aws_opensearch_domain.main.endpoint
}

# ── ALB ───────────────────────────────────────────────────────────────────────
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

# ── S3 ────────────────────────────────────────────────────────────────────────
output "s3_data_bucket_name" {
  description = "Name of the data S3 bucket"
  value       = aws_s3_bucket.data.id
}

output "s3_financials_bucket_name" {
  description = "Name of the financials S3 bucket"
  value       = aws_s3_bucket.financials.id
}

output "s3_operations_bucket_name" {
  description = "Name of the operations S3 bucket"
  value       = aws_s3_bucket.operations.id
}

output "s3_data_science_bucket_name" {
  description = "Name of the data-science S3 bucket"
  value       = aws_s3_bucket.data_science.id
}

output "s3_logs_bucket_name" {
  description = "Name of the logs S3 bucket"
  value       = aws_s3_bucket.logs.id
}

# ── SQS ───────────────────────────────────────────────────────────────────────
output "sqs_work_queue_url" {
  description = "URL of the Lambda work SQS queue"
  value       = aws_sqs_queue.lambda_work_queue.url
}

output "sqs_dlq_url" {
  description = "URL of the Lambda dead-letter SQS queue"
  value       = aws_sqs_queue.lambda_work_dlq.url
}

# ── KMS ───────────────────────────────────────────────────────────────────────
output "kms_rds_key_arn" {
  description = "ARN of the RDS KMS key"
  value       = aws_kms_key.rds.arn
}

output "kms_s3_key_arn" {
  description = "ARN of the S3 KMS key"
  value       = aws_kms_key.s3.arn
}

output "kms_eks_secrets_key_arn" {
  description = "ARN of the EKS secrets KMS key"
  value       = aws_kms_key.eks_secrets.arn
}

output "kms_logs_key_arn" {
  description = "ARN of the CloudWatch Logs KMS key"
  value       = aws_kms_key.logs.arn
}

# ── SNS ───────────────────────────────────────────────────────────────────────
output "alarms_sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  value       = aws_sns_topic.alarms.arn
}
