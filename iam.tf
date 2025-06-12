resource "aws_iam_role" "lambda_exec" {
  name = local.lambda_exec_role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = { Service = "lambda.amazonaws.com" },
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_access" {
  name       = "lambda-access-${random_pet.suffix.id}"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}