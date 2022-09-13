resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = length(var.azs) > 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name" = format(
        "${local.vpc_name}-public-%s",
        element(var.azs, count.index),
      )
    },
    var.public_subnet_tags,
    var.tags
  )
}

resource "aws_subnet" "private" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.key
  availability_zone = length(each.value.az) > 0 ? each.value.az : null

  tags = merge(
    {
      "Name" = format("${local.vpc_name}-private-%s", each.value.az)
    },
    each.value.tags,
    var.tags
  )
}