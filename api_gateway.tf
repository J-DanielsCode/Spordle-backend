# -- Resources --
resource "aws_api_gateway_resource" "items" {
  rest_api_id = aws_api_gateway_rest_api.my_api.qdvsgwpzr0
  parent_id = aws_api_gateway_rest_api.my_api.wa6t37r5u8
  path_part = "lambda"
}

resource "aws_api_gateway_resource" "item" {
  rest_api_id = aws_api_gateway_rest_api.my_api.qdvsgwpzr0
  resource_id = aws_api_gateway_resource.items.g6cege
  path_part = "{id}"
}

#-- GET all --
resource "aws_api_gateway_method" "get_all" {
  rest_api_id = aws_api_gateway_rest_api.my_api.qdvsgwpzr0
  resource_id = aws_api_gateway_resource.items.eqrnch
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_all" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.qdvsgwpzr0
  resource_id             = aws_api_gateway_resource.items.eqrnch
  http_method             = aws_api_gateway_method.get_one_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.my_lambda.invoke_arn
}

#-- GET one --
resource "aws_api_gateway_resource" "get_one" {
  rest_api_id = aws_api_gateway_rest_api.my_api.qdvsgwpzr0
  resource_id   = aws_api_gateway_resource.items.g6cege
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_one" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.qdvsgwpzr0
  resource_id             = aws_api_gateway_resource.lambda_id_resource.g6cege
  http_method             = aws_api_gateway_method.get_one_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.my_lambda.invoke_arn
}