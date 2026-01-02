# IAM role dor API gateway logs
resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  name = "APIGatewayCloudWatchLogsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      },
    ]
  })
}

# Policy that grants log writing permissions
resource "aws_iam_role_policy" "api_gateway_cloudwatch_policy" {
  name = "APIGatewayCloudWatchLogsPolicy"
  role = aws_iam_role.api_gateway_cloudwatch_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}
# Setting up REST API
resource "aws_api_gateway_rest_api" "player_data_api" {
  name = "NBA-player-api"
  description = "api endpoint for nab player data"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Resources
resource "aws_api_gateway_resource" "status_resource" {
  parent_id = aws_api_gateway_rest_api.player_data_api.root_resource_id
  path_part = "status"
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
}

resource "aws_api_gateway_resource" "all_players_resource" {
  parent_id = aws_api_gateway_rest_api.player_data_api.root_resource_id
  path_part = "players"
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
}

resource "aws_api_gateway_resource" "one_player_resource" {
  parent_id = aws_api_gateway_resource.all_players_resource.id
  path_part = "{player_id}"
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
}


# API status methods
resource "aws_api_gateway_method" "status_get" {
  authorization = "NONE"
  http_method = "GET"
  resource_id = aws_api_gateway_resource.status_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
}

resource "aws_api_gateway_method" "status_options" {
  authorization = "NONE"
  http_method = "OPTIONS"
  resource_id = aws_api_gateway_resource.status_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
}

# API status integrations
resource "aws_api_gateway_integration" "status_get_integration" {
  http_method = aws_api_gateway_method.status_get.http_method
  resource_id = aws_api_gateway_resource.status_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_integration" "status_options_integration" {
  http_method = aws_api_gateway_method.status_options.http_method
  resource_id = aws_api_gateway_resource.status_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
  type = "MOCK"
}

# API all players methods
resource "aws_api_gateway_method" "players_get_all" {
  authorization = "NONE"
  http_method = "GET"
  resource_id = aws_api_gateway_resource.all_players_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
}

resource "aws_api_gateway_method" "players_options" {
  authorization = "NONE"
  http_method = "OPTIONS"
  resource_id = aws_api_gateway_resource.all_players_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
}

# API all players integration
resource "aws_api_gateway_integration" "get_all_integration" {
  http_method = aws_api_gateway_method.players_get_all.http_method
  resource_id = aws_api_gateway_resource.all_players_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_integration" "get_all_options_integration" {
  http_method = aws_api_gateway_method.players_options.http_method
  resource_id = aws_api_gateway_resource.all_players_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
  type = "MOCK"
}

# API one player methods
resource "aws_api_gateway_method" "one_player_options" {
  authorization = "NONE"
  http_method = "OPTIONS"
  resource_id = aws_api_gateway_resource.one_player_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
}

resource "aws_api_gateway_method" "one_player_get" {
  authorization = "NONE"
  http_method = "GET"
  resource_id = aws_api_gateway_resource.one_player_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
}

resource "aws_api_gateway_method" "one_player_delete" {
  authorization = "NONE"
  http_method = "DELETE"
  resource_id = aws_api_gateway_resource.one_player_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
}

resource "aws_api_gateway_method" "one_player_patch" {
  authorization = "NONE"
  http_method = "PATCH"
  resource_id = aws_api_gateway_resource.one_player_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
}

resource "aws_api_gateway_method" "one_player_post" {
  authorization = "NONE"
  http_method = "POST"
  resource_id = aws_api_gateway_resource.one_player_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
}

# One player integrations
resource "aws_api_gateway_integration" "get_one_integration" {
  http_method = aws_api_gateway_method.one_player_get.http_method
  resource_id = aws_api_gateway_resource.one_player_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
  type = "AWS_PROXY"
}

resource "aws_api_gateway_integration" "delete_one_integration" {
  http_method = aws_api_gateway_method.one_player_delete.http_method
  resource_id = aws_api_gateway_resource.one_player_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_integration" "patch_one_integration" {
  http_method = aws_api_gateway_method.one_player_patch.http_method
  resource_id = aws_api_gateway_resource.one_player_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_integration" "post_one_integration" {
  http_method = aws_api_gateway_method.one_player_post.http_method
  resource_id = aws_api_gateway_resource.one_player_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_integration" "one_player_options_integration" {
  http_method = aws_api_gateway_method.one_player_options.http_method
  resource_id = aws_api_gateway_resource.one_player_resource.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
  type = "MOCK"
}

# API deployment
resource "aws_api_gateway_deployment" "player_data_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      #status
      aws_api_gateway_resource.status_resource.id,
      aws_api_gateway_method.status_get.id,
      aws_api_gateway_method.status_options.id,
      aws_api_gateway_integration.status_get_integration.id,
      aws_api_gateway_integration.status_options_integration.id,
      #all players
      aws_api_gateway_resource.all_players_resource.id,
      aws_api_gateway_method.players_get_all.id,
      aws_api_gateway_method.players_options.id,
      aws_api_gateway_integration.get_all_integration.id,
      aws_api_gateway_integration.get_all_options_integration.id,
      #one player
      aws_api_gateway_resource.one_player_resource.id,
      aws_api_gateway_method.one_player_get.id,
      aws_api_gateway_method.one_player_options.id,
      aws_api_gateway_method.one_player_delete.id,
      aws_api_gateway_method.one_player_patch.id,
      aws_api_gateway_method.one_player_post.id,
      aws_api_gateway_integration.get_one_integration.id,
      aws_api_gateway_integration.delete_one_integration.id,
      aws_api_gateway_integration.patch_one_integration.id,
      aws_api_gateway_integration.post_one_integration.id,
      aws_api_gateway_integration.one_player_options_integration.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "players_api_stage" {
  deployment_id = aws_api_gateway_deployment.player_data_api_deployment.id
  rest_api_id = aws_api_gateway_rest_api.player_data_api.id
  stage_name = "production_2.0"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
    format = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
  }

  # For finding function invocation problems
  xray_tracing_enabled = true

  depends_on = [aws_iam_role.api_gateway_cloudwatch_role]

  lifecycle {
    ignore_changes = [ 
      variables
    ]
  }

  variables = {
    "logging_level" = "INFO" #choice is INFO or ERROR, INFO = less detail, ERROR = errors only
  }
}

output "base_api_url" {
  description = "The base invocation url for the API Gateway (Stage: production_2.0)"
  value = aws_api_gateway_stage.players_api_stage.invoke_url
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.player_data_api.execution_arn}/*"
}