# ── Aurora PostgreSQL ─────────────────────────────────────────────────────────
resource "aws_db_subnet_group" "aurora" {
  name        = "${local.name_prefix}-aurora-subnet-grp"
  description = "Subnet group for Aurora PostgreSQL cluster"
  subnet_ids  = var.private_db_subnet_ids

  tags = {
    Name = "${local.name_prefix}-aurora-subnet-grp"
  }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier        = "${local.name_prefix}-aurora"
  engine                    = "aurora-postgresql"
  engine_version            = var.aurora_engine_version
  database_name             = "terragoat"
  master_username           = "aurora_admin"
  master_password           = random_password.aurora_master.result
  db_subnet_group_name      = aws_db_subnet_group.aurora.name
  vpc_security_group_ids    = [aws_security_group.aurora.id]
  storage_encrypted         = true
  kms_key_id                = aws_kms_key.rds.arn
  backup_retention_period   = var.aurora_backup_retention_days
  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${local.name_prefix}-aurora-final"
  apply_immediately         = false

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Name = "${local.name_prefix}-aurora"
  }
}

resource "aws_rds_cluster_instance" "aurora_writer" {
  identifier              = "${local.name_prefix}-aurora-writer"
  cluster_identifier      = aws_rds_cluster.aurora.id
  instance_class          = var.aurora_instance_class
  engine                  = aws_rds_cluster.aurora.engine
  engine_version          = aws_rds_cluster.aurora.engine_version
  db_subnet_group_name    = aws_db_subnet_group.aurora.name
  publicly_accessible     = false
  monitoring_interval     = 60
  monitoring_role_arn     = aws_iam_role.rds_monitoring.arn
  performance_insights_enabled = true
  performance_insights_kms_key_id = aws_kms_key.rds.arn

  tags = {
    Name = "${local.name_prefix}-aurora-writer"
  }
}

resource "aws_rds_cluster_instance" "aurora_reader" {
  identifier              = "${local.name_prefix}-aurora-reader"
  cluster_identifier      = aws_rds_cluster.aurora.id
  instance_class          = var.aurora_instance_class
  engine                  = aws_rds_cluster.aurora.engine
  engine_version          = aws_rds_cluster.aurora.engine_version
  db_subnet_group_name    = aws_db_subnet_group.aurora.name
  publicly_accessible     = false
  monitoring_interval     = 60
  monitoring_role_arn     = aws_iam_role.rds_monitoring.arn
  performance_insights_enabled = true
  performance_insights_kms_key_id = aws_kms_key.rds.arn

  tags = {
    Name = "${local.name_prefix}-aurora-reader"
  }
}

# ── Neptune Graph Database ────────────────────────────────────────────────────
resource "aws_neptune_subnet_group" "main" {
  name        = "${local.name_prefix}-neptune-subnet-grp"
  description = "Subnet group for Neptune graph database"
  subnet_ids  = var.private_db_subnet_ids

  tags = {
    Name = "${local.name_prefix}-neptune-subnet-grp"
  }
}

resource "aws_neptune_cluster" "main" {
  cluster_identifier                  = "${local.name_prefix}-neptune"
  engine                              = "neptune"
  neptune_subnet_group_name           = aws_neptune_subnet_group.main.name
  vpc_security_group_ids              = [aws_security_group.neptune.id]
  storage_encrypted                   = true
  kms_key_arn                         = aws_kms_key.rds.arn
  iam_database_authentication_enabled = true
  backup_retention_period             = var.neptune_backup_retention_days
  deletion_protection                 = true
  skip_final_snapshot                 = false
  final_snapshot_identifier           = "${local.name_prefix}-neptune-final"
  apply_immediately                   = false

  tags = {
    Name = "${local.name_prefix}-neptune"
  }
}

resource "aws_neptune_cluster_instance" "main" {
  count              = 2
  identifier         = "${local.name_prefix}-neptune-${count.index}"
  cluster_identifier = aws_neptune_cluster.main.id
  instance_class     = var.neptune_instance_class

  tags = {
    Name = "${local.name_prefix}-neptune-${count.index}"
  }
}
