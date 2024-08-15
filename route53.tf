data "aws_route53_zone" "example" {
  name = var.domain
}
resource "aws_route53_record" "web_ssl_validation" {
  for_each = { for opt in aws_acm_certificate.web.domain_validation_options : opt.domain_name => opt }

  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  zone_id = data.aws_route53_zone.example.id
  records = [each.value.resource_record_value]
  ttl     = 300
}

resource "aws_route53_record" "web_cloudfront" {
  zone_id = data.aws_route53_zone.example.id
  name    = local.name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.web.domain_name
    zone_id                = aws_cloudfront_distribution.web.hosted_zone_id
    evaluate_target_health = true
  }
}
