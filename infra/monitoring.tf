# ── SNS Topic for Alarms ──────────────────────────────────────────────────────
resource "aws_sns_topic" "alarms" {
  name              = "${local.name_prefix}-alarms"
  kms_master_key_id = aws_kms_key.logs.id

  tags = {
    Name = "${local.name_prefix}-alarms"
  }
}

locals {
  alarm_actions = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : [aws_sns_topic.alarms.arn]
}

# ── CloudWatch Log Groups ─────────────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${local.name_prefix}-eks/cluster"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn

  tags = {
    Name = "${local.name_prefix}-eks-logs"
  }
}

resource "aws_cloudwatch_log_group" "lambda_main" {
  name              = "/aws/lambda/${local.name_prefix}-function"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn

  tags = {
    Name = "${local.name_prefix}-lambda-logs"
  }
}

resource "aws_cloudwatch_log_group" "rds_postgresql" {
  name              = "/aws/rds/cluster/${local.name_prefix}-aurora/postgresql"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn

  tags = {
    Name = "${local.name_prefix}-rds-logs"
  }
}

resource "aws_cloudwatch_log_group" "neptune" {
  name              = "/aws/neptune/${local.name_prefix}-neptune/audit"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn

  tags = {
    Name = "${local.name_prefix}-neptune-logs"
  }
}

resource "aws_cloudwatch_log_group" "opensearch" {
  name              = "/aws/opensearch/${var.project_name}-opensearch"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn

  tags = {
    Name = "${local.name_prefix}-opensearch-logs"
  }
}

resource "aws_cloudwatch_log_group" "waf_logs" {
  name              = "aws-waf-logs-${var.project_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.logs.arn

  tags = {
    Name = "${local.name_prefix}-waf-logs"
  }
}

# ── ALB Alarms ────────────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "alb_5xx_error_rate" {
  alarm_name          = "${local.name_prefix}-alb-5xx-error-rate-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "ALB 5xx error count exceeds threshold"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = { Name = "${local.name_prefix}-alb-5xx" }
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${local.name_prefix}-alb-unhealthy-host-count-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "ALB has unhealthy targets"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.main.arn_suffix
  }

  tags = { Name = "${local.name_prefix}-alb-unhealthy" }
}

resource "aws_cloudwatch_metric_alarm" "alb_target_response_time" {
  alarm_name          = "${local.name_prefix}-alb-target-response-time-p99-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  extended_statistic  = "p99"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  threshold           = 1.0
  alarm_description   = "ALB p99 target response time exceeds 1 second"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = { Name = "${local.name_prefix}-alb-latency" }
}

# ── Lambda Alarms ─────────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${local.name_prefix}-lambda-error-rate-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Lambda error count exceeds threshold"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.main.function_name
  }

  tags = { Name = "${local.name_prefix}-lambda-errors" }
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${local.name_prefix}-lambda-throttle-rate-warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Lambda throttle count exceeds threshold"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.main.function_name
  }

  tags = { Name = "${local.name_prefix}-lambda-throttles" }
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration_p99" {
  alarm_name          = "${local.name_prefix}-lambda-p99-duration-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  extended_statistic  = "p99"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 60
  threshold           = 25000
  alarm_description   = "Lambda p99 duration exceeds 25 seconds"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.main.function_name
  }

  tags = { Name = "${local.name_prefix}-lambda-duration" }
}

# ── RDS Aurora Alarms ─────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${local.name_prefix}-rds-cpu-utilization-warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU utilization exceeds 80%"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.cluster_identifier
  }

  tags = { Name = "${local.name_prefix}-rds-cpu" }
}

resource "aws_cloudwatch_metric_alarm" "rds_freeable_memory" {
  alarm_name          = "${local.name_prefix}-rds-freeable-memory-warning"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 3
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 268435456
  alarm_description   = "RDS freeable memory below 256 MB"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.cluster_identifier
  }

  tags = { Name = "${local.name_prefix}-rds-memory" }
}

resource "aws_cloudwatch_metric_alarm" "rds_replica_lag" {
  alarm_name          = "${local.name_prefix}-rds-replica-lag-warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "AuroraReplicaLag"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 1000
  alarm_description   = "Aurora replica lag exceeds 1 second"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.cluster_identifier
  }

  tags = { Name = "${local.name_prefix}-rds-replica-lag" }
}

# ── Neptune Alarms ────────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "neptune_cpu" {
  alarm_name          = "${local.name_prefix}-neptune-cpu-utilization-warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/Neptune"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Neptune CPU utilization exceeds 80%"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_neptune_cluster.main.cluster_identifier
  }

  tags = { Name = "${local.name_prefix}-neptune-cpu" }
}

resource "aws_cloudwatch_metric_alarm" "neptune_gremlin_errors" {
  alarm_name          = "${local.name_prefix}-neptune-gremlin-error-rate-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "GremlinRequestsPerSec"
  namespace           = "AWS/Neptune"
  period              = 60
  statistic           = "Sum"
  threshold           = 100
  alarm_description   = "Neptune Gremlin request rate anomaly"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_neptune_cluster.main.cluster_identifier
  }

  tags = { Name = "${local.name_prefix}-neptune-gremlin" }
}

# ── OpenSearch Alarms ─────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "opensearch_cluster_red" {
  alarm_name          = "${local.name_prefix}-opensearch-cluster-status-red-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ClusterStatus.red"
  namespace           = "AWS/ES"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "OpenSearch cluster status is RED"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    DomainName = aws_opensearch_domain.main.domain_name
    ClientId   = data.aws_caller_identity.current.account_id
  }

  tags = { Name = "${local.name_prefix}-opensearch-red" }
}

resource "aws_cloudwatch_metric_alarm" "opensearch_free_storage" {
  alarm_name          = "${local.name_prefix}-opensearch-free-storage-critical"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/ES"
  period              = 60
  statistic           = "Minimum"
  threshold           = 5120
  alarm_description   = "OpenSearch free storage below 5 GB"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    DomainName = aws_opensearch_domain.main.domain_name
    ClientId   = data.aws_caller_identity.current.account_id
  }

  tags = { Name = "${local.name_prefix}-opensearch-storage" }
}

resource "aws_cloudwatch_metric_alarm" "opensearch_jvm_memory" {
  alarm_name          = "${local.name_prefix}-opensearch-jvm-memory-warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "JVMMemoryPressure"
  namespace           = "AWS/ES"
  period              = 60
  statistic           = "Maximum"
  threshold           = 85
  alarm_description   = "OpenSearch JVM memory pressure exceeds 85%"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    DomainName = aws_opensearch_domain.main.domain_name
    ClientId   = data.aws_caller_identity.current.account_id
  }

  tags = { Name = "${local.name_prefix}-opensearch-jvm" }
}

# ── SQS Alarms ────────────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "sqs_dlq_depth" {
  alarm_name          = "${local.name_prefix}-sqs-dlq-message-count-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Messages in Lambda DLQ — investigate failures"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.lambda_work_dlq.name
  }

  tags = { Name = "${local.name_prefix}-sqs-dlq" }
}

resource "aws_cloudwatch_metric_alarm" "sqs_queue_age" {
  alarm_name          = "${local.name_prefix}-sqs-queue-age-warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 3600
  alarm_description   = "Oldest SQS message age exceeds 1 hour"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.lambda_work_queue.name
  }

  tags = { Name = "${local.name_prefix}-sqs-age" }
}

# ── KMS Alarms ────────────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "kms_unauthorized_usage" {
  alarm_name          = "${local.name_prefix}-kms-unauthorized-key-usage-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NumberOfRequestsFailedDueToInvalidKeyState"
  namespace           = "AWS/KMS"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "KMS key usage failures detected"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  tags = { Name = "${local.name_prefix}-kms-unauthorized" }
}

# ── EKS Alarms ────────────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "eks_node_cpu" {
  alarm_name          = "${local.name_prefix}-eks-node-cpu-warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EKS node CPU utilization exceeds 80%"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
  }

  tags = { Name = "${local.name_prefix}-eks-cpu" }
}

resource "aws_cloudwatch_metric_alarm" "eks_node_memory" {
  alarm_name          = "${local.name_prefix}-eks-node-memory-warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "node_memory_utilization"
  namespace           = "ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EKS node memory utilization exceeds 80%"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
  }

  tags = { Name = "${local.name_prefix}-eks-memory" }
}

# ── WAF Alarms ────────────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "waf_sqli_triggered" {
  alarm_name          = "${local.name_prefix}-waf-sqli-rule-triggered-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "AWSManagedRulesSQLiRuleSet"
  namespace           = "AWS/WAFV2"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "WAF SQLi rule triggered more than 10 times in 5 minutes"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    WebACL = aws_wafv2_web_acl.main.name
    Region = var.aws_region
    Rule   = "AWSManagedRulesSQLiRuleSet"
  }

  tags = { Name = "${local.name_prefix}-waf-sqli" }
}

# ── Secrets Manager Alarm ─────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "secrets_rotation_failure" {
  alarm_name          = "${local.name_prefix}-secrets-rotation-failure-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Secrets rotation Lambda encountered errors"
  alarm_actions       = local.alarm_actions
  ok_actions          = local.alarm_actions
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.secrets_rotation.function_name
  }

  tags = { Name = "${local.name_prefix}-secrets-rotation-failure" }
}
