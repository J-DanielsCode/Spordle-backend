resource "aws_iam_role" "lambda_exec_role" {
  name = "nba_api_lambda_role"
  description = "Grants lambda CRUD access to DynamoDB and CloudWatch logging."

  assume_role_policy = jsondecode({
    Version = "2012-12-17"
    Statement = [
        {
            Action = "sts:AssumeRole"
            Principal = {
                Service = "lambda.amazonaws.com"
            }
            Sid = "DynamoDBCrudAccess"
            Effect = "Allow"
            Action = [
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem",
                "dynamodb:DeleteItem"
            ]
            Resource = "arn:aws:dynamodb:eu-west-2:098597569789:table/nba-player-data"
        },
        {
            Sid = "CloudWatchLogsAccess"
            Effect = "Allow"
            Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
            Resource = "arn:aws:logs:eu-west-2:098597569789:log-group:/aws/lambda/api_processor:*"
        }
    ]
  })
}

resource "aws_lambda_function" "nba_api_lambda" {
  function_name = "nba_api_processor"
  role = aws_iam_role.lambda_exec_role.arn
  runtime = "python3.13"
  handler = "lambda_function.lambda_handler"

  filename = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")
  environment {
    variables = {
      ENVIRONMENT = "dev"
    }
  }
}