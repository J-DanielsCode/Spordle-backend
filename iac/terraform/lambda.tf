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

    resources = ["*"]
  }
}

#DYnamoDB policy document, Policy and attachment
data "aws_iam_policy_document" "lambda_dynamoDB_policy" {
  statement {
    effect = "Allow"
    actions = [ 
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [ 
      "arn:aws:dynamodb:eu-west-2:098597569789:table/nba-player-data",
      "arn:aws:dynamodb:eu-west-2:098597569789:table/nba-player-data/index/unique_id"
    ]
  }
}

resource "aws_iam_policy" "lambda_dynamoDB_exec_policy" {
  name = "lambda_dynamodb_access"
  description = "Allows lambda to access NBA player data table"
  policy = data.aws_iam_policy_document.lambda_dynamoDB_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_dynamoDB_exec_policy.arn
}

resource "aws_iam_role" "iam_for_lambda" {
  name                  = "lambda_execution_role"
  assume_role_policy    = data.aws_iam_policy_document.assume_role.json  
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name = "lambda_cloudwatch_logging"
  description = "IAM policy for lambda to write logs to CloudWatch"
  policy = data.aws_iam_policy_document.lambda_cloudwatch_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs_attach" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

# Package the lambda function code
data "archive_file" "lambda" {
  type = "zip"
  source_file = "${path.module}./../src/lambda_function.py"
  output_path = "${path.module}./lambda_function_src.zip"
}

# Lambda function
resource "aws_lambda_function" "lambda" {
  filename = data.archive_file.lambda.output_path
  function_name = "player_api_lambda_function"
  role = aws_iam_role.iam_for_lambda.arn
  
  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.13"
  handler = "lambda_function.lambda_handler"
}