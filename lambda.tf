data "aws_iam_policy_document" "assume_role" {
  statement {
    sid    = "AssumeRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "allow_sns" {
  statement {
    sid       = "AllowSNS"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "allow_sns" {
  name   = "${random_pet.name.id}-AllowSNS"
  policy = data.aws_iam_policy_document.allow_sns.json
}

resource "aws_iam_role" "lambda_role" {
  name               = "${random_pet.name.id}-LambdaRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "sns_topic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.allow_sns.arn
}

resource "aws_lambda_function" "s3ToSNS" {
  s3_bucket     = aws_s3_bucket.forLambdas.id
  s3_key        = aws_s3_object.s3ToSNS.key
  function_name = "${random_pet.name.id}-TriggerNotification"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main"
  runtime       = "go1.x"

  environment {
    variables = {
      S3TOPIC = "${aws_sns_topic.s3_topic.arn}"
    }
  }

  lifecycle {
    replace_triggered_by = [
      aws_s3_object.s3ToSNS.etag
    ]
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "${random_pet.name.id}-AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3ToSNS.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.content.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.content.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.s3ToSNS.arn
    events = [
      "s3:ObjectCreated:*",
      "s3:ObjectRemoved:*",
    ]
  }
  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_s3_bucket" "forLambdas" {
  bucket        = "${random_pet.name.id}-lambda-zip"
  force_destroy = true
}

resource "aws_s3_object" "s3ToSNS" {
  bucket           = aws_s3_bucket.forLambdas.id
  key              = "pkg.zip"
  source           = "pkg.zip"
  etag             = filemd5("pkg.zip")
  content_type     = "application/zip"
  content_language = "en-US"
}