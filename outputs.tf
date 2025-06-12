output "s3_bucket_name" {
  value = aws_s3_bucket.energy_bucket.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.energy_data.name
}

output "lambda_exec_role_name" {
  value = aws_iam_role.lambda_exec.name
}

output "eventbridge_rule" {
  value = aws_cloudwatch_event_rule.every_5_min.name
}

output "s3_trigger_status" {
  value = "S3 -> Lambda trigger set up"
}