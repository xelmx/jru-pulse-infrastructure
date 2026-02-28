resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = "ALB-Origin"

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only" 
      origin_ssl_protocols = ["TLSv1.2"]
    }
  }

  enabled = true
  is_ipv6_enabled  = true
  default_root_object = "index.php"

  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]
    target_origin_id = "ALB-Origin"

    forwarded_values {
      query_string = true
      cookies {
        forward = "all" 
      }
      headers = ["*"]
    }

    viewer_protocol_policy = "redirect-to-https" 
    min_ttl = 0 
    default_ttl = 0
    max_ttl = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "${var.project_name}-cf"
  }
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.main.domain_name
}