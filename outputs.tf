output "s3_website_endpoint" {
  value = aws_s3_bucket_website_configuration.configuration.website_endpoint
}

output "cloudfront_website_endpoint" {
  value = aws_cloudfront_distribution.s3_dist.domain_name
}