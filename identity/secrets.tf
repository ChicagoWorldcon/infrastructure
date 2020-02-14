resource "aws_secretsmanager_secret" "db_superuser_password" {
  name = "${var.project}/db/${var.db_name}/${var.db_username}/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "DB Superuser",
      "ServiceName", "ChicagoAdmin"
    )
  )
}

resource "aws_secretsmanager_secret" "db_admin_password" {
  name = "${var.project}/db/${var.db_name}/${var.db_admin_username}/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "DB Admin",
      "ServiceName", "ChicagoAdmin"
    )
  )
}

resource "aws_secretsmanager_secret" "db_kansa_password" {
  name = "${var.project}/db/${var.db_name}/kansa/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "DB Kansa",
      "ServiceName", "ChicagoRegistration"
    )
  )
}

resource "aws_secretsmanager_secret" "db_hugo_password" {
  name = "${var.project}/db/${var.db_name}/hugo/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "DB Hugo",
      "ServiceName", "ChicagoRegistration"
    )
  )
}

resource "aws_secretsmanager_secret" "db_raami_password" {
  name = "${var.project}/db/${var.db_name}/raami/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "DB Raami",
      "ServiceName", "ChicagoRegistration"
    )
  )
}

resource "aws_secretsmanager_secret" "stripe_api_key" {
  name = "${var.project}/stripe_api_key/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "Stripe API Key",
      "ServiceName", "ChicagoRegistration"
    )
  )
}

resource "aws_secretsmanager_secret" "session_secret" {
  name = "${var.project}/tokens/session/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "API session secret",
      "ServiceName", "ChicagoRegistration"
    )
  )
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name = "${var.project}/tokens/jwt/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "API JWT secret",
      "ServiceName", "ChicagoRegistration"
    )
  )
}

resource "aws_secretsmanager_secret" "sendgrid_api_key" {
  name = "${var.project}/sendgrid_api_key/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "API email system key for sendgrid",
      "ServiceName", "ChicagoRegistration"
    )
  )
}
