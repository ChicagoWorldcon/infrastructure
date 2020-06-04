resource "aws_security_group" "postgresql" {
  vpc_id = aws_vpc.chicagovpc.id

  tags = merge(
    local.common_tags,
    map("Name", "dgDatabaseServer")
  )
}

resource "aws_db_subnet_group" "rds-subnets" {
  name        = "default-rds-${aws_vpc.chicagovpc.id}"
  description = "${var.project} RDS subnets"
  subnet_ids = [
    aws_subnet.subnet-az-a.id,
    aws_subnet.subnet-az-b.id,
    aws_subnet.subnet-az-c.id,
  ]

  tags = merge(
    local.common_tags,
    map("Name", "RDS Subnet Group")
  )
}

resource "aws_security_group_rule" "db-ingress-dev" {
  type                     = "ingress"
  security_group_id        = aws_security_group.postgresql.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  description              = "Security group allowing access from the reg server"
  source_security_group_id = module.registration.dev.security_group_id
}

resource "aws_security_group_rule" "db-ingress" {
  type                     = "ingress"
  security_group_id        = aws_security_group.postgresql.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  description              = "Security group allowing access from the reg server"
  source_security_group_id = module.registration.prod.security_group_id
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "chicago-worldcon-prod"

  engine            = "postgres"
  engine_version    = "9.6.15"
  instance_class    = "db.t2.micro"
  allocated_storage = "20"
  storage_encrypted = false

  username = var.db_superuser_username
  password = data.aws_secretsmanager_secret_version.db_superuser_password.secret_string
  port     = "5432"

  vpc_security_group_ids = [aws_security_group.postgresql.id]

  maintenance_window = "sun:04:30-sun:05:30"
  backup_window      = "04:00-04:30"

  backup_retention_period = "30"

  tags = merge(
    local.common_tags,
    map("Name", "DatabaseServer")
  )

  # DB subnet group
  db_subnet_group_name = aws_db_subnet_group.rds-subnets.name

  # DB parameter group
  family = "postgres9.6"

  # DB option group
  major_engine_version = "9.6"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "terraform-aws-postgresql-rds-snapshot"

  # Database Deletion Protection
  deletion_protection = true
}
