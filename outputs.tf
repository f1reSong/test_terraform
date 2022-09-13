
output "alb_arn" {
  value = aws_lb.main.arn
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "dns_zone" {
  value = aws_route53_zone.main.name
}

output "nat_gw_public_ips" {
  value = {
    for ngw in aws_nat_gateway.main : ngw.tags.Name => ngw.public_ip
  }
}

output "nat_gw_private_ips" {
  value = {
    for ngw in aws_nat_gateway.main : ngw.tags.Name => ngw.private_ip
  }
}

output "public_route_table_arn" {
  value = aws_route_table.public.arn
}