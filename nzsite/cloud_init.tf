data "template_file" "script" {
  template = file("${path.module}/scripts/cloud_init.yml")

  vars = {
    project                    = var.project
    db_hostname                = var.db_hostname
    db_superuser_username      = var.db_superuser_username
    db_site_username           = var.db_site_username
    db_name                    = var.db_name
    db_superuser_secret        = var.db_superuser_secret
    stage                      = var.stage
    aws_region                 = var.region
    app_name                   = var.app_name
    deployment_group           = var.deployment_group_name
    codedeploy_agent_s3_bucket = "aws-codedeploy-us-west-2.s3.amazonaws.com"

    # shell tools for the service
    rotate_creds = base64encode("${data.template_file.rotate_creds.rendered}")
    db_env_vars  = base64encode("${data.template_file.db_env_vars_script.rendered}")
    prompt_file  = base64encode("${data.template_file.shell_prompt.rendered}")

    # service initializationa and config
    caddyfile            = base64encode("${data.template_file.caddyfile.rendered}")
    registration_service = base64encode("${data.template_file.registration_service.rendered}")
    docker_daemon_json   = base64encode("${data.template_file.docker_daemon_json.rendered}")
    docker_compose       = base64encode(file("${path.module}/scripts/docker-compose.yml"))

    # env files for services
    www_env_file     = base64encode("${data.template_file.www_env_vars_file.rendered}")
    sidekiq_env_file = base64encode("${data.template_file.sidekiq_env_vars_file.rendered}")
    service_env_file = base64encode("${data.template_file.service_env_vars_file.rendered}")
  }
}

data "template_file" "rotate_creds" {
  template = file("${path.module}/scripts/rotate-creds.sh")

  vars = {
    devise_secret   = var.session_secret
    jwt_secret      = var.jwt_secret
    stripe_secret   = var.stripe_secret
    sendgrid_secret = var.sendgrid_secret
    postgres_secret = var.db_site_secret
    sidekiq_secret  = var.sidekiq_secret
  }
}

data "template_file" "db_env_vars_script" {
  template = file("${path.module}/scripts/db-env-vars.sh")

  vars = {
    project               = var.project
    db_hostname           = var.db_hostname
    db_superuser_username = var.db_superuser_username
    db_site_username      = var.db_site_username
    db_site_secret        = var.db_site_secret
    db_name               = var.db_name
    stage                 = var.stage
  }
}

data "template_file" "shell_prompt" {
  template = file("${path.module}/scripts/set-instance-prompt.sh")

  vars = {
    colour_code = var.instance_prompt_colour
    stage       = var.stage
  }
}

data "template_file" "caddyfile" {
  template = file("${path.module}/scripts/Caddyfile.tpl")

  vars = {
    stage               = var.stage
    www_domain_name     = var.www_domain_name
    sidekiq_domain_name = var.sidekiq_domain_name
    admin_email         = "it@${var.domain_name}"
    test_cert           = var.use_test_certs
  }
}

data "template_file" "registration_service" {
  template = file("${path.module}/scripts/registration.service")

  vars = {
    db_hostname     = var.db_hostname
    db_name         = var.db_name
    www_domain_name = var.www_domain_name
  }
}

data "template_file" "docker_daemon_json" {
  template = file("${path.module}/scripts/daemon.json")

  vars = {
    log_group = aws_cloudwatch_log_group.registration_group.name
  }
}

data "template_file" "www_env_vars_file" {
  template = file("${path.module}/scripts/hostname.env")
  vars = {
    fqdn = var.www_domain_name
  }
}

data "template_file" "sidekiq_env_vars_file" {
  template = file("${path.module}/scripts/hostname.env")
  vars = {
    fqdn = var.sidekiq_domain_name
  }
}

data "template_file" "service_env_vars_file" {
  template = file("${path.module}/scripts/static_service_env")

  vars = {
    domain_name = var.domain_name

    db_hostname      = var.db_hostname
    db_site_username = var.db_site_username
    db_name          = var.db_name
  }
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.script.rendered
  }
}

