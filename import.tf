resource "aws_api_gateway_rest_api" "my_api" {
  name = "nba_rest_api_gateway"
}

resource "aws_dynamodb_table" "my_table" {
  name = "nba_player_data_table"
}