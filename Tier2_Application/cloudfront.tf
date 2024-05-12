#ACM:
#Creating:
# resource "aws_acm_certificate" "cert" {
#   domain_name       = "cloudcraftsmanlab.com"
#   validation_method = "DNS"

#   tags = {
#     Environment = "test"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

#Using the created cert:
data "aws_acm_certificate" "issued" {
  domain   = "cloudcraftsmanlab.com"
  statuses = ["ISSUED"]
}



resource "aws_cloudfront_distribution" "Tier2App_distribution" {
  origin {
    domain_name              = aws_lb.Tier2App-alb.dns_name
    # origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = aws_lb.Tier2App-alb.dns_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

#   logging_config {
#     include_cookies = false
#     bucket          = "mylogs.s3.amazonaws.com"
#     prefix          = "myprefix"
#   }

  aliases = ["cloudcraftsmanlab.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_lb.Tier2App-alb.dns_name

    forwarded_values {
      headers = []
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  

#   price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Name = "Tier2App-CF"
    Environment = "production"
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.issued.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}