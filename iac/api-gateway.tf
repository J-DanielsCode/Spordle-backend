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