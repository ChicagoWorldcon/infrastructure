resource "aws_secretsmanager_secret" "db_superuser_password" {
  name = "${var.project}/db/${var.db_name}/${var.db_superuser_username}/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.stage} DB Superuser",
      "ServiceName", "ChicagoAdmin"
    )
  )
}

resource "aws_secretsmanager_secret" "db_site_password" {
  name = "${var.project}/db/${var.db_name}/${var.db_site_username}/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.stage} DB Admin",
      "ServiceName", "ChicagoAdmin"
    )
  )
}

