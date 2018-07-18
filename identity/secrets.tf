resource "aws_secretsmanager_secret" "db_superuser_password" {
  name = "${var.project}/db/${var.db_name}/${var.db_username}/${terraform.workspace}"

  tags {
    Project = "${var.project}"
    Name = "DB Superuser"
    Environment = "${terraform.workspace}"
    ServiceName = "ChicagoAdmin"
  } 
}

resource "aws_secretsmanager_secret" "db_admin_password" {
  name = "${var.project}/db/${var.db_name}/${var.db_admin_username}/${terraform.workspace}"

  tags {
    Project = "${var.project}"
    Name = "DB Admin"
    Environment = "${terraform.workspace}"
    ServiceName = "ChicagoAdmin"
  } 
}

resource "aws_secretsmanager_secret" "db_kansa_password" {
  name = "${var.project}/db/${var.db_name}/kansa/${terraform.workspace}"

  tags {
    Project = "${var.project}"
    Name = "DB Kansa"
    Environment = "${terraform.workspace}"
    ServiceName = "ChicagoRegistration"
  } 
}

resource "aws_secretsmanager_secret" "db_hugo_password" {
  name = "${var.project}/db/${var.db_name}/hugo/${terraform.workspace}"

  tags {
    Project = "${var.project}"
    Name = "DB Hugo"
    Environment = "${terraform.workspace}"
    ServiceName = "ChicagoRegistration"
  } 
}

resource "aws_secretsmanager_secret" "db_raami_password" {
  name = "${var.project}/db/${var.db_name}/raami/${terraform.workspace}"

  tags {
    Project = "${var.project}"
    Name = "DB Raami"
    Environment = "${terraform.workspace}"
    ServiceName = "ChicagoRegistration"
  } 
}

