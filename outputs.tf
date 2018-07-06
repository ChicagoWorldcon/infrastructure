output "bastion_public_ip" {
  value = "${module.bastion_host.bastion_ip}"
}

output "db_endpoint" {
  value = "${module.postgresql_rds.endpoint}"
}

output "db_hostname" {
  value = "${module.postgresql_rds.hostname}"
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
