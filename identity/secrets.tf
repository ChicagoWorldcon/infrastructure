resource "aws_secretsmanager_secret" "db_site_password" {
  name = "${var.project}/db/${var.db_name}/${var.db_site_username}/${var.stage}"

  tags = merge(
    var.common_tags,
    tomap({
      "Name"        = "${var.stage} DB Admin",
      "ServiceName" = "ChicagoAdmin"
    })
  )
}

