locals {
  vpc_name = "${var.prefix}-${var.vpc_name}"
}


resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = merge(
    {
      Name = local.vpc_name
    },
    var.vpc_tags,
    var.tags
  )
}