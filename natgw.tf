resource "aws_eip" "nat" {
  for_each = aws_subnet.private
  vpc      = true
  tags = merge(
    {
      "Name" = format("${local.vpc_name}-%s", each.key)
    },
    var.tags
  )
}

resource "aws_nat_gateway" "main" {
  for_each = aws_subnet.private

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = element(aws_subnet.public[*].id, index(keys(aws_subnet.private), each.key))

  tags = merge(
    {
      "Name" = format("${local.vpc_name}-nat-gw-%s", index(keys(aws_subnet.private), each.key))
    },
    var.tags,
  )

  depends_on = [aws_internet_gateway.main]
}