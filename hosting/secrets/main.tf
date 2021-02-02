resource "aws_secretsmanager_secret" "stripe_api_key" {
  name = "${var.project}/stripe_api_key/${var.stage}"

  tags = merge(
    var.common_tags,
    map(
      "Name", "${var.stage} Stripe API Key",
      "Project", var.project,
      "Environment", var.stage,
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
      "Project", var.project,
      "Environment", var.stage,
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
      "Project", var.project,
      "Environment", var.stage,
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
      "Project", var.project,
      "Environment", var.stage,
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
      "Project", var.project,
      "Environment", var.stage,
      "ServiceName", "ChicagoRegistration"
    )
  )
}
