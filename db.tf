resource "aws_security_group" "postgresql" {
  vpc_id = aws_vpc.chicagovpc.id

  tags = merge(
    local.common_tags,
    map("Name", "dgDatabaseServer")
  )
}

resource "aws_db_instance" "reg-db" {
  allocated_storage          = "20"
  engine                     = "postgres"
  engine_version             = "9.6.15"
  identifier                 = "chicago-worldcon-prod"
  snapshot_identifier        = ""
  instance_class             = "db.t2.micro"
  storage_type               = "gp2"
  name                       = var.db_name
  password                   = data.aws_secretsmanager_secret_version.db_superuser_password.secret_string
  username                   = var.db_username
  backup_retention_period    = "30"
  backup_window              = "04:00-04:30"
  maintenance_window         = "sun:04:30-sun:05:30"
  auto_minor_version_upgrade = false
  final_snapshot_identifier  = "terraform-aws-postgresql-rds-snapshot"
  skip_final_snapshot        = true
  copy_tags_to_snapshot      = false
  multi_az                   = false
  port                       = "5432"
  vpc_security_group_ids     = [aws_security_group.postgresql.id]
  db_subnet_group_name       = aws_db_subnet_group.rds-subnets.name
  parameter_group_name       = "default.postgres9.6"
  storage_encrypted          = false

  tags = merge(
    local.common_tags,
    map("Name", "DatabaseServer")
    )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_security_group_rule" "db-ingress-dev" {
  type                     = "ingress"
  security_group_id        = aws_security_group.postgresql.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  description              = "Security group allowing access from the reg server"
  source_security_group_id = module.dev-site.security_group_id
}

resource "aws_security_group_rule" "db-ingress" {
  type                     = "ingress"
  security_group_id        = aws_security_group.postgresql.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  description              = "Security group allowing access from the reg server"
  source_security_group_id = module.prod-site.security_group_id
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

