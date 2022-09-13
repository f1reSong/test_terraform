resource "aws_internet_gateway" "main" {

  vpc_id = aws_vpc.main.id

  tags = merge(
    { "Name" = "${local.vpc_name}-igw" },
    var.tags,
    var.igw_tags,
  )
}