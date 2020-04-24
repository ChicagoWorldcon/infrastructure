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

resource "aws_secretsmanager_secret" "db_kansa_password" {
  name = "${var.project}/db/${var.db_name}/kansa/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.stage} DB Kansa",
      "ServiceName", "ChicagoRegistration"
    )
  )
}

resource "aws_secretsmanager_secret" "db_hugo_password" {
  name = "${var.project}/db/${var.db_name}/hugo/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.stage} DB Hugo",
      "ServiceName", "ChicagoRegistration"
    )
  )
}

resource "aws_secretsmanager_secret" "db_raami_password" {
  name = "${var.project}/db/${var.db_name}/raami/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.stage} DB Raami",
      "ServiceName", "ChicagoRegistration"
    )
  )
}

resource "aws_secretsmanager_secret" "stripe_api_key" {
  name = "${var.project}/stripe_api_key/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.stage} Stripe API Key",
      "ServiceName", "ChicagoRegistration"
      )
    )
}

resource "aws_secretsmanager_secret" "session_secret" {
  name = "${var.project}/tokens/session/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.stage} API session secret",
      "ServiceName", "ChicagoRegistration"
    )
  )
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name = "${var.project}/tokens/jwt/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.stage} API JWT secret",
      "ServiceName", "ChicagoRegistration"
    )
  )
}

resource "aws_secretsmanager_secret" "sendgrid_api_key" {
  name = "${var.project}/sendgrid_api_key/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.stage} API email system key for sendgrid",
      "ServiceName", "ChicagoRegistration"
    )
  )
}

resource "aws_secretsmanager_secret" "sidekiq_password" {
  name = "${var.project}/sidekiq_password/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.stage} Password for queue admin",
      "ServiceName", "ChicagoRegistration"
      )
    )
}
