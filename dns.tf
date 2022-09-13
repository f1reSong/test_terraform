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