resource "aws_s3_bucket" "web_log" {
  bucket        = "${local.name}-log"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "web_log" {
  bucket = aws_s3_bucket.web_log.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "web_log" {
  bucket = aws_s3_bucket.web_log.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.web_log,
  ]
}

resource "aws_s3_bucket" "web_content" {
  bucket        = "${local.name}-root"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "web_content" {
  bucket = aws_s3_bucket.web_content.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "web_content" {
  bucket = aws_s3_bucket.web_content.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "web_content" {
  bucket                  = aws_s3_bucket.web_content.id
  block_public_acls       = "true"
  ignore_public_acls      = "true"
  block_public_policy     = "true"
  restrict_public_buckets = "true"
}

resource "aws_s3_bucket_logging" "web_content" {
  bucket = aws_s3_bucket.web_content.id

  target_bucket = aws_s3_bucket.web_log.id
  target_prefix = "s3/"
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.web_content.bucket
  key          = "index.html"
  content_type = "text/html"
  content      = <<EOF
<!doctype html>
<html>
<head>
    <title>Hello!</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
        }
        h1 {
            color: #333;
        }
        p {
            color: #666;
        }
    </style>
</head>
<body>
    <h1>Hello, World!</h1>
</body>
</html>
EOF
}

resource "aws_s3_object" "error_html" {
  bucket       = aws_s3_bucket.web_content.bucket
  key          = "error.html"
  content_type = "text/html"
  content      = <<EOF
<!doctype html>
<html>
<head>
    <title>404 Not Found</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
        }
        h1 {
            color: #333;
        }
        p {
            color: #666;
        }
    </style>
</head>
<body>
    <h1>Oops! Page Not Found</h1>
    <p>We couldn't find the page you're looking for.</p>
    <p>Please check the URL for errors or return to the <a href="/">homepage</a>.</p>
    <p>If you believe this is a mistake, please contact our <a href="mailto:support@example.com">support team</a>.</p>
</body>
</html>
EOF
}

resource "aws_s3_bucket_policy" "web_content_allow_public_access" {
  bucket = aws_s3_bucket.web_content.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.web.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.web_content.arn}/*"
      }
    ]
  })

  depends_on = [
    aws_s3_bucket.web_content,
    aws_s3_bucket_website_configuration.web_content,
    aws_s3_bucket_public_access_block.web_content
  ]
}
