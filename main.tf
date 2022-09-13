provider "aws" {
  region = var.aws_region
}

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

resource "aws_internet_gateway" "main" {

  vpc_id = aws_vpc.main.id

  tags = merge(
    { "Name" = "${local.vpc_name}-igw" },
    var.tags,
    var.igw_tags,
  )
}

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id

  tags = merge(
    { "Name" = "${local.vpc_name}-public" },
    var.tags,
    var.public_route_table_tags,
  )
}

resource "aws_route" "public_internet_gateway" {

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id = element(aws_subnet.public[*].id, count.index)
  route_table_id = element(
    aws_route_table.public[*].id, count.index
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

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route" "private_nat_gateway" {
  for_each = aws_route_table.private

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[each.key].id
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.private
  vpc = true
  tags = merge(
    {
      "Name" = format( "${local.vpc_name}-%s", each.key )
    },
    var.tags
  )
}

resource "aws_nat_gateway" "main" {
  for_each = aws_subnet.private

  allocation_id = aws_eip.nat[each.key].id
  subnet_id = element(aws_subnet.public[*].id, index(keys(aws_subnet.private), each.key))

  tags = merge(
    {
      "Name" = format( "${local.vpc_name}-%s", index(keys(aws_subnet.private), each.key) )
    },
    var.tags,
  )

  depends_on = [aws_internet_gateway.main]
}

resource "aws_security_group" "http_and_https_sg" {
  name        = "allow_http and https"
  description = "Allow http and https inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTPS from internet"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP from internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      "Name" = "${local.vpc_name}-web-sg"
    },
    var.tags,
  )
}

resource "aws_lb" "main" {
  name               = "${var.prefix}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.http_and_https_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  enable_deletion_protection = false

  tags = merge(
    var.tags,
  )
}

resource "aws_route53_zone" "main" {
  name = var.domain
}

resource "aws_route53_record" "cname_to_lb" {
  zone_id = aws_route53_zone.main.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}