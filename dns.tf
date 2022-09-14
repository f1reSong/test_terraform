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

resource "aws_acm_certificate" "cert" {
  domain_name       = aws_route53_zone.main.name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_route53_record" "cert_validation" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  records         = [ tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value ]
  type            = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
  zone_id  = aws_route53_zone.main.zone_id
  ttl      = 60
}

# This tells terraform to cause the route53 validation to happen
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [ aws_route53_record.cert_validation.fqdn ]
}