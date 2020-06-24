# Create the resources that all stages need.
resource "aws_secretsmanager_secret" "db_superuser_password" {
  name = "${var.project}/db/db_superuser_password"

  tags = merge(
    var.common_tags,
    map(
      "Name", "DB Superuser",
      "ServiceName", "ChicagoAdmin"
    )
  )
}

