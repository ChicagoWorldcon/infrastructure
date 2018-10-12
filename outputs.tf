output "db_endpoint" {
  value = "${aws_db_instance.reg-db.endpoint}"
}

output "db_hostname" {
  value = "${aws_db_instance.reg-db.address}"
}

output "db_instance_id" {
  value = "${aws_db_instance.reg-db.id}"
}

output "reg_hostname" {
  value = "${aws_instance.web.public_dns}"
}

output "reg_private_ip" {
  value = "${aws_instance.web.private_ip}"
}

output "reg_public_ip" {
  value = "${aws_instance.web.public_ip}"
}

output "reg_public_dns" {
  value = "${aws_instance.web.public_dns}"
}

output "reg_instance_id" {
  value = "${aws_instance.web.id}"
}

output "global_ns" {
  value = "${data.terraform_remote_state.global.name_servers}"
}

output "site" {
  value = "${local.workspace["reg-www"]}.${var.domain_name}"
}

output "api-address" {
  value = "${local.workspace["reg-api"]}.${var.domain_name}"
}

output "api-port" {
  value = "443"
}

output "www-bucket" {
  value = "${module.client.s3_bucket_name}"
}

