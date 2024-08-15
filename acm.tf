resource "aws_acm_certificate" "web" {
  provider                  = aws.us_east_1
  domain_name               = local.name
  subject_alternative_names = [local.name]
  validation_method         = "DNS"
}

resource "aws_acm_certificate_validation" "web" {
  provider        = aws.us_east_1
  certificate_arn = aws_acm_certificate.web.arn

  validation_record_fqdns = [
    for record in aws_route53_record.web_ssl_validation : record.fqdn
  ]

  depends_on = [
    aws_route53_record.web_ssl_validation
  ]
}
