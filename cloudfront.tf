resource "aws_cloudfront_distribution" "s3_dist" {
  enabled = true
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = aws_s3_bucket_website_configuration.configuration.website_endpoint
    compress               = true
    cache_policy_id        = aws_cloudfront_cache_policy.example.id
  }
  origin {
    origin_id           = aws_s3_bucket_website_configuration.configuration.website_endpoint
    domain_name         = aws_s3_bucket.content.bucket_regional_domain_name
    connection_attempts = 3
    connection_timeout  = 10
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.mine.cloudfront_access_identity_path
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  is_ipv6_enabled     = true
  comment             = "${random_pet.name.id} static website distribution"
  default_root_object = aws_s3_object.index_html.key
  price_class         = "PriceClass_100"
}

resource "aws_cloudfront_origin_access_identity" "mine" {
  comment = "${random_pet.name.id}-MyOAI"
}

resource "aws_cloudfront_cache_policy" "example" {
  name        = "${random_pet.name.id}-CachePolicy"
  default_ttl = 50
  max_ttl     = 100
  min_ttl     = 1
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "whitelist"
      cookies {
        items = ["example"]
      }
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["example"]
      }
    }
    query_strings_config {
      query_string_behavior = "whitelist"
      query_strings {
        items = ["example"]
      }
    }
  }
}