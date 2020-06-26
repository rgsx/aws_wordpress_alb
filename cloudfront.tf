resource "aws_cloudfront_distribution" "distribution_wordpress" {
  enabled = true
  viewer_certificate {
    acm_certificate_arn = var.acm-certificate-arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  aliases = ["cicd.me.uk","www.cicd.me.uk"]

  origin {
    domain_name = aws_alb.alb-wordpress.dns_name
    origin_id   = aws_alb.alb-wordpress.id

    custom_origin_config {
      http_port              = 80
      https_port              = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2", "SSLv3"]
    }
    }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
  
    forwarded_values {
      headers      = ["*"]
      query_string = true

      cookies {
        forward = "all"
      }
    }
    
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    target_origin_id       = aws_alb.alb-wordpress.id
  }

  ordered_cache_behavior {
    path_pattern     = "/wp_content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_alb.alb-wordpress.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "allow-all"
  }

  ordered_cache_behavior {
    path_pattern     = "/wp_includes/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_alb.alb-wordpress.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "allow-all"
  }
}