resource "aws_sns_topic" "s3_topic" {
  name              = "${random_pet.name.id}-S3ContentNotifications"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "s3_topic_subscription" {
  endpoint  = var.subscription_email
  protocol  = "email"
  topic_arn = aws_sns_topic.s3_topic.arn
}