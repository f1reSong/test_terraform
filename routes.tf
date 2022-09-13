resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id

  tags = merge(
    { "Name" = "${local.vpc_name}-public" },
    var.tags,
    var.public_route_table_tags,
  )
}

resource "aws_route_table" "private" {
  for_each = var.private_subnets

  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      "Name" = format("${local.vpc_name}-private-%s", each.value.az)
    },
    var.tags,
    each.value.tags,
  )
}

resource "aws_route" "public_internet_gateway" {

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "private_nat_gateway" {
  for_each = aws_route_table.private

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[each.key].id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id = element(aws_subnet.public[*].id, count.index)
  route_table_id = element(
    aws_route_table.public[*].id, count.index
  )
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}