locals {
  cloud_init_script = templatefile("${path.module}/scripts/cloud_init.yml", {
    instance_launch_script = base64encode(templatefile("${path.module}/scripts/bootstrap.sh", {}))
    install_codedeploy_script = base64encode(templatefile("${path.module}/scripts/install-codedeploy.sh", {
      codedeploy_agent_s3_bucket = "aws-codedeploy-us-west-2.s3.amazonaws.com"
    }))
  })
}

data "cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = local.cloud_init_script
  }
}

