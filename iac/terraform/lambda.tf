# IAM role for lambda function
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type          = "Service"
      identifiers   = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name                  = "lambda_execution_role"
  assume_role_policy    = data.aws_iam_policy_document.assume_role
}

# Package the lambda function code
data "archive_file" "lambda" {
  type = "zip"
  source_file = "${path.module}../../src/lambda_function.py"
  output_path = "lambda_function_src.zip"
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