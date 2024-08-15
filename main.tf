
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  name = "web.${random_string.suffix.result}.${var.domain}"

}

output "cloudfront_distribution_dns_name" {
  value = aws_cloudfront_distribution.web.domain_name
}

output "route53_web_dns_name" {
  value = aws_route53_record.web_cloudfront.fqdn
}

output "route53_web_url" {
  value = "https://${aws_route53_record.web_cloudfront.fqdn}"
}
