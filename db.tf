resource "aws_security_group" "postgresql" {
  vpc_id = "${aws_vpc.chicagovpc.id}"

  tags {
    Name        = "sgDatabaseServer"
    Project     = "${var.project}"
  }
}

resource "aws_db_instance" "postgresql" {
  allocated_storage          = "20"
  engine                     = "postgres"
  engine_version             = "9.6.6"
  identifier                 = "chicago-worldcon"
  snapshot_identifier        = ""
  instance_class             = "db.t2.micro"
  storage_type               = "gp2"
  name                       = "${var.db_name}"
  password                   = "${var.db_username}"
  username                   = "${var.db_password}"
  backup_retention_period    = "30"
  backup_window              = "04:00-04:30"
  maintenance_window         = "sun:04:30-sun:05:30"
  auto_minor_version_upgrade = false
  final_snapshot_identifier  = "terraform-aws-postgresql-rds-snapshot"
  skip_final_snapshot        = true
  copy_tags_to_snapshot      = false
  multi_az                   = false
  port                       = "5432"
  vpc_security_group_ids     = ["${aws_security_group.postgresql.id}"]
  db_subnet_group_name       = "${aws_db_subnet_group.rds-subnets.name}"
  parameter_group_name       = "default.postgres9.6"
  storage_encrypted          = false

  tags {
    Name        = "DatabaseServer"
    Project     = "${var.project}"
  }
}

resource "aws_security_group_rule" "db-ingress" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.postgresql.id}"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  description = "Security group allowing access from the reg server"
  source_security_group_id = "${aws_security_group.web_server_sg.id}"
}

resource "aws_db_subnet_group" "rds-subnets" {
  name        = "default-vpc-6a628612"
  description = "${var.project} RDS subnets"
  subnet_ids  = [
    "${aws_subnet.subnet-az-a.id}",
    "${aws_subnet.subnet-az-b.id}",
    "${aws_subnet.subnet-az-c.id}",
  ]

  tags {
    Project = "${var.project}"
  }
}

