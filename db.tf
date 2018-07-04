module "postgresql_rds" {
  source = "github.com/azavea/terraform-aws-postgresql-rds"
  vpc_id = "${aws_vpc.chicagovpc.id}"
  allocated_storage = "20"
  engine_version = "9.6.6"
  instance_type = "db.t2.micro"
  storage_type = "gp2"
  database_identifier = "chicago-worldcon"
  database_name = "chicago"
  database_username = "monkee"
  database_password = "barrelof"
  database_port = "5432"
  backup_retention_period = "30"
  backup_window = "04:00-04:30"
  maintenance_window = "sun:04:30-sun:05:30"
  auto_minor_version_upgrade = false
  multi_availability_zone = false
  storage_encrypted = false
  subnet_group = "${aws_db_subnet_group.rds-subnets.name}"
  parameter_group = "default.postgres9.6"

  alarm_cpu_threshold = "75"
  alarm_disk_queue_threshold = "10"
  alarm_free_disk_threshold = "5000000000"
  alarm_free_memory_threshold = "128000000"
  # alarm_actions = ["arn:aws:sns..."]
  # ok_actions = ["arn:aws:sns..."]
  # insufficient_data_actions = ["arn:aws:sns..."]
  alarm_actions = []
  ok_actions = []
  insufficient_data_actions = []

  project = "${var.project}"
  environment = "Staging"
}

resource "aws_security_group_rule" "db-ingress" {
  type                     = "ingress"
  security_group_id        = "${module.postgresql_rds.database_security_group_id}"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  description = "Security group allowing access from the reg server"
  source_security_group_id = "${module.web_server_sg.this_security_group_id}"
}

resource "aws_db_subnet_group" "rds-subnets" {
  name        = "default-vpc-6a628612"
  description = "Created from the RDS Management Console"
  subnet_ids  = [
    "${aws_subnet.subnet-az-a.id}",
    "${aws_subnet.subnet-az-b.id}",
    "${aws_subnet.subnet-az-c.id}",
  ]

  tags {
    Project = "${var.project}"    
  }
}

