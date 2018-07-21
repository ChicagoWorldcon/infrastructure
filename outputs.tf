output "db_endpoint" {
  value = "${aws_db_instance.reg-db.endpoint}"
}

output "db_hostname" {
  value = "${aws_db_instance.reg-db.address}"
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

output "global_ns" {
  value = "${data.terraform_remote_state.global.name_servers}"
}

output "site" {
  value = "${var.reg-www}.${var.domain_name}"
}
