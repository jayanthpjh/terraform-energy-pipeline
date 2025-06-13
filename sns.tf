resource "aws_sns_topic" "anomaly_alert" {
  name = local.sns_topic_name
}