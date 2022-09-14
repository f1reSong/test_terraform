resource "aws_lb" "main" {
  name                       = "${var.prefix}-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.http_and_https_sg.id]
  subnets                    = [for subnet in aws_subnet.public : subnet.id]
  enable_deletion_protection = false

  tags = merge(
    var.tags,
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response http"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.cert.arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response https"
      status_code  = "200"
    }
  }
  depends_on = [
    aws_acm_certificate_validation.cert
  ]
}