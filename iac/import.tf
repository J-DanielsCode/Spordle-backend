resource "aws_api_gateway_rest_api" "my_api" {
  name = "NBA_data_api"
}

resource "aws_dynamodb_table" "my_table" {
    name         = "nba-player-data"
    billing_mode = "PAY_PER_REQUEST"

    hash_key     = "player_id"

    attribute {
        name = "player_id"
        type = "N"
    }
}

