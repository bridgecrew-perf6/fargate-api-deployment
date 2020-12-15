resource "aws_cloudwatch_log_group" "cw_log_group_service" {
  name = "${local.service_stage}-service-log-group"

  tags = {
    Environment = local.service_stage
    Application = "service"
  }
}

resource "aws_cloudwatch_log_stream" "cw_log_stream_service" {
  name           = "${local.service_stage}-service"
  log_group_name = aws_cloudwatch_log_group.cw_log_group_service.name
}

