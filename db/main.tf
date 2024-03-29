resource "aws_security_group" "postgresql" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    local.common_tags,
    tomap({
      "Name" = "DB Security Group"
    })
  )
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "chicon-shared"

  engine            = "postgres"
  engine_version    = var.db_engine_version
  instance_class    = "db.m6g.large"
  allocated_storage = "100"
  storage_encrypted = false

  username = var.db_superuser_username
  password = var.db_superuser_password
  port     = "5432"

  performance_insights_enabled = true

  vpc_security_group_ids = [aws_security_group.postgresql.id]

  maintenance_window = "sun:04:30-sun:05:30"
  backup_window      = "04:00-04:30"

  backup_retention_period = "7"

  tags = merge(
    var.tags,
    local.common_tags,
    tomap({ "Name" = "DatabaseServer" })
  )

  # DB subnet group
  create_db_subnet_group = false
  db_subnet_group_name   = var.db_subnet_group_name

  # DB parameter group
  family = "postgres${var.db_engine_major_version}"

  # DB option group
  major_engine_version = var.db_engine_major_version

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "terraform-aws-postgresql-rds-snapshot"

  # Database Deletion Protection
  deletion_protection = true
}
