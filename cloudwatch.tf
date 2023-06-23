resource "aws_cloudwatch_dashboard" "default" {
  dashboard_name = "${random_pet.name.id}-ServerlessApp"
  dashboard_body = jsonencode(
    {
      "widgets" : [
        {
          "type" : "metric",
          "x" : 0,
          "y" : 0,
          "width" : 6,
          "height" : 6,
          "properties" : {
            "view" : "timeSeries",
            "stacked" : true,
            "metrics" : [
              ["AWS/SNS", "NumberOfNotificationsDelivered", "TopicName", "${aws_sns_topic.s3_topic.name}", { "region" : "${var.region}" }],
              ["AWS/SNS", "NumberOfNotificationsFailed", "TopicName", "${aws_sns_topic.s3_topic.name}", { "region" : "${var.region}" }]
            ],
            "region" : "${var.region}",
            "period" : 60,
            "stat" : "SampleCount",
            "title" : "Notifications"
          }
        },
        {
          "type" : "metric",
          "x" : 6,
          "y" : 0,
          "width" : 6,
          "height" : 6,
          "properties" : {
            "metrics" : [
              ["AWS/Lambda", "Invocations", { "region" : "${var.region}" }]
            ],
            "sparkline" : true,
            "view" : "singleValue",
            "region" : "${var.region}",
            "period" : 60,
            "title" : "Lambda invocations",
            "stat" : "SampleCount"
          }
        }
      ]
    }
  )
}