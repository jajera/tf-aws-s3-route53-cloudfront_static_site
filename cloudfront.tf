resource "aws_cloudfront_origin_access_identity" "web" {
  comment = local.name
}

resource "aws_cloudfront_distribution" "web" {
  enabled = true
  aliases = [local.name]

  custom_error_response {
    error_code            = 403
    response_page_path    = "/error.html"
    response_code         = 403
    error_caching_min_ttl = 300
  }

  custom_error_response {
    error_code            = 404
    response_page_path    = "/error.html"
    response_code         = 404
    error_caching_min_ttl = 300
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]
    compress        = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = "0"
    default_ttl            = "300"
    max_ttl                = "1200"
    target_origin_id       = "origin-${aws_s3_bucket.web_content.id}"
    viewer_protocol_policy = "redirect-to-https"
  }

  default_root_object = "index.html"

  logging_config {
    bucket = aws_s3_bucket.web_log.bucket_domain_name
    prefix = "cloudfront/"
  }

  origin {
    origin_id   = "origin-${aws_s3_bucket.web_content.id}"
    domain_name = aws_s3_bucket.web_content.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.web.cloudfront_access_identity_path
    }
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.web.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
