# IAM role for lambda function
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type          = "Service"
      identifiers   = ["lambda.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
    ]

  }
}

data "aws_iam_policy_document" "lambda_cloudwatch_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = "*"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name                  = "lambda_execution_role"
  assume_role_policy    = data.aws_iam_policy_document.assume_role  
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name = "lambda_cloudwatch_logging"
  description = "IAM policy for lambda to write logs to CloudWatch"
  policy = data.aws_iam_policy_document.lambda_cloudwatch_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs_attach" {
  role = aws_iam_role.iam_for_lambda.lambda_execution_role
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

# Package the lambda function code
data "archive_file" "lambda" {
  type = "zip"
  source_file = "${path.module}../../src/lambda_function.py"
  output_path = "${path.module}../lambda_function_src.zip"
}

# Lambda function
resource "aws_lambda_function" "lambda" {
  filename = data.archive_file.lambda.output_path
  function_name = "player_api_lambda_function"
  role = aws_iam_role.iam_for_lambda.arn
  
  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.13"
  handler = "lambda_handler"
}