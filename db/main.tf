resource "aws_security_group" "postgresql" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    local.common_tags,
    tomap({
      "Name" = "DB Security Group"
    })
  )
}

