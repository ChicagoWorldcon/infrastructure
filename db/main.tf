resource "aws_security_group" "postgresql" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    local.common_tags,
  )
}

# resource "aws_security_group_rule" "db-ingress-dev" {
#   type                     = "ingress"
#   security_group_id        = aws_security_group.postgresql.id
#   from_port                = 5432
#   to_port                  = 5432
#   protocol                 = "tcp"
#   description              = "Security group allowing access from the reg server"
#   source_security_group_id = module.registration.dev.security_group_id
# }

# resource "aws_security_group_rule" "db-ingress" {
#   type                     = "ingress"
#   security_group_id        = aws_security_group.postgresql.id
#   from_port                = 5432
#   to_port                  = 5432
#   protocol                 = "tcp"
#   description              = "Security group allowing access from the reg server"
#   source_security_group_id = module.registration.prod.security_group_id
# }

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "chicon-shared"

  engine            = "postgres"
  engine_version    = "12.3"
  instance_class    = "db.t2.micro"
  allocated_storage = "20"
  storage_encrypted = false

  username = var.db_superuser_username
  password = var.db_superuser_password
  port     = "5432"

  vpc_security_group_ids = [aws_security_group.postgresql.id]

  maintenance_window = "sun:04:30-sun:05:30"
  backup_window      = "04:00-04:30"

  backup_retention_period = "30"

  tags = merge(
    var.tags,
    local.common_tags,
    map("Name", "DatabaseServer")
  )

  # DB subnet group
  db_subnet_group_name = var.db_subnet_group_name

  # DB parameter group
  family = "postgres12.3"

  # DB option group
  major_engine_version = "12.3"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "terraform-aws-postgresql-rds-snapshot"

  # Database Deletion Protection
  deletion_protection = true
}
