resource "aws_lambda_function" "data_simulator" {
  filename         = "lambda/data_simulator.zip"
  function_name    = "data-simulator"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "data_simulator.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("lambda/data_simulator.zip")

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.energy_bucket.bucket
    }
  }
}

resource "aws_lambda_function" "data_processor" {
  filename         = "lambda/data_processor.zip"
  function_name    = "data-processor"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "data_processor.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("lambda/data_processor.zip")

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.energy_data.name
	  SNS_TOPIC_ARN = aws_sns_topic.anomaly_alert.arn
    }
  }
}