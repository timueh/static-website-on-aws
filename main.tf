resource "random_pet" "name" {
  prefix = var.prefix
  length = 1
}

locals {
  index_html = "index.html"
}

# bucket to host static website
resource "aws_s3_bucket" "content" {
  bucket        = "${random_pet.name.id}-content"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.content.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "configuration" {
  bucket = aws_s3_bucket.content.id

  index_document {
    suffix = local.index_html
  }

  error_document {
    key = "error.html"
  }

}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.content.id
  policy = data.aws_iam_policy_document.public_access_policy.json
}

data "aws_iam_policy_document" "public_access_policy" {
  statement {
    sid    = "${random_pet.name.id}-AllowPublicGetObject"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.mine.iam_arn]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.content.arn}/*"]
  }

}

resource "aws_s3_object" "index_html" {
  bucket           = aws_s3_bucket.content.id
  key              = local.index_html
  source           = local.index_html
  etag             = filemd5(local.index_html)
  content_language = "en-US"
  content_type     = "text/html"
}