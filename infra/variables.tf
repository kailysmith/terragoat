variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terragoat"
}

variable "environment" {
  description = "Deployment environment (e.g. prod, staging)"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

# ── User-supplied networking ──────────────────────────────────────────────────
variable "vpc_id" {
  description = "ID of the user-supplied VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs (for ALB)"
  type        = list(string)
}

variable "private_app_subnet_ids" {
  description = "List of private application subnet IDs (EKS nodes, Lambda, OpenSearch)"
  type        = list(string)
}

variable "private_db_subnet_ids" {
  description = "List of private database subnet IDs (RDS, Neptune)"
  type        = list(string)
}

# ── EKS ───────────────────────────────────────────────────────────────────────
variable "eks_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.29"
}

variable "eks_node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "eks_node_desired_count" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 3
}

variable "eks_node_min_count" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "eks_node_max_count" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 6
}

# ── ECR ───────────────────────────────────────────────────────────────────────
variable "ecr_lifecycle_policy_days" {
  description = "Number of days after which untagged ECR images are expired"
  type        = number
  default     = 90
}

# ── Lambda ────────────────────────────────────────────────────────────────────
variable "lambda_runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "nodejs20.x"
}

variable "lambda_reserved_concurrency" {
  description = "Reserved concurrency for Lambda function"
  type        = number
  default     = 100
}

# ── RDS Aurora PostgreSQL ─────────────────────────────────────────────────────
variable "aurora_engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "15.4"
}

variable "aurora_instance_class" {
  description = "Instance class for Aurora cluster members"
  type        = string
  default     = "db.t3.medium"
}

variable "aurora_backup_retention_days" {
  description = "Number of days to retain Aurora automated backups"
  type        = number
  default     = 14
}

# ── Neptune ───────────────────────────────────────────────────────────────────
variable "neptune_instance_class" {
  description = "Instance class for Neptune cluster members"
  type        = string
  default     = "db.t3.medium"
}

variable "neptune_backup_retention_days" {
  description = "Number of days to retain Neptune automated backups"
  type        = number
  default     = 7
}

# ── OpenSearch ────────────────────────────────────────────────────────────────
variable "opensearch_version" {
  description = "OpenSearch engine version"
  type        = string
  default     = "OpenSearch_2.11"
}

variable "opensearch_instance_type" {
  description = "Instance type for OpenSearch data nodes"
  type        = string
  default     = "t3.medium.search"
}

variable "opensearch_instance_count" {
  description = "Number of OpenSearch data nodes"
  type        = number
  default     = 2
}

variable "opensearch_ebs_volume_size" {
  description = "EBS volume size in GiB for each OpenSearch node"
  type        = number
  default     = 30
}

variable "create_opensearch_service_linked_role" {
  description = "Set to false if the OpenSearch service-linked role already exists in the account"
  type        = bool
  default     = true
}

# ── WAF ───────────────────────────────────────────────────────────────────────
variable "waf_rate_limit_threshold" {
  description = "Maximum number of requests per 5-minute window per IP before rate limiting"
  type        = number
  default     = 2000
}

# ── KMS ───────────────────────────────────────────────────────────────────────
variable "kms_deletion_window_days" {
  description = "Number of days before a scheduled KMS key deletion takes effect"
  type        = number
  default     = 30
}

# ── Secrets Manager ───────────────────────────────────────────────────────────
variable "secrets_rotation_days" {
  description = "Number of days between automatic secret rotations"
  type        = number
  default     = 30
}

# ── S3 ────────────────────────────────────────────────────────────────────────
variable "s3_bucket_suffix" {
  description = "Random suffix appended to S3 bucket names for global uniqueness"
  type        = string
  default     = ""
}

# ── Observability ─────────────────────────────────────────────────────────────
variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 90
}

variable "alarm_sns_topic_arn" {
  description = "ARN of the SNS topic to receive CloudWatch alarm notifications"
  type        = string
  default     = ""
}
