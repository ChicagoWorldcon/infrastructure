data "template_file" "script" {
  template = file("${path.module}/scripts/cloud_init.yml")

  vars = {
    # service initializationa and config
    instance_launch_script    = base64encode("${data.template_file.bootstrap.rendered}")
    install_codedeploy_script = base64encode("${data.template_file.install_codedeploy.rendered}")
    docker_daemon_json        = base64encode("${data.template_file.docker_daemon_json.rendered}")
  }
}

data "template_file" "bootstrap" {
  template = file("${path.module}/scripts/bootstrap.sh")
}

data "template_file" "install_codedeploy" {
  template = file("${path.module}/scripts/install-codedeploy.sh")

  vars = {
    codedeploy_agent_s3_bucket = "aws-codedeploy-us-west-2.s3.amazonaws.com"
  }
}

data "template_file" "docker_daemon_json" {
  template = file("${path.module}/scripts/docker-daemon-${var.docker_log_driver}.json")

  vars = {
    log_group = aws_cloudwatch_log_group.registration_group.name
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

