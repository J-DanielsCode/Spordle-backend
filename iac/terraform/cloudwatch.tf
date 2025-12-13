resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name = "/aws/api-gateway/${aws_api_gateway_rest_api.player_data_api.id}/production_2.0"
  retention_in_days = 30
}