output "cloudfront_website_endpoint" {
  value = aws_cloudfront_distribution.s3_dist.domain_name
}