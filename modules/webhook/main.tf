data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_s3_object" "lambda_s3_bucket" {
  bucket = local.lambda_bucket
  key    = "webhook.zip"
}

locals {
  webhook_endpoint = "webhook"
  lambda_bucket    = "${var.stack_name}-${var.prefix}-${terraform.workspace}-bucket"
  tags = {
    Name        = "${var.stack_name}-${var.prefix}-webhook"
    Environment = terraform.workspace
  }
  default_runner_labels = "self-hosted,${var.runner_os},${var.runner_architecture}"
  runner_labels         = var.runner_extra_labels != "" ? "${local.default_runner_labels},${var.runner_extra_labels}" : local.default_runner_labels
}

resource "aws_apigatewayv2_api" "webhook" {
  name          = "${var.stack_name}-${var.prefix}-webhook"
  protocol_type = "HTTP"
  tags          = local.tags
}

resource "aws_apigatewayv2_route" "webhook" {
  api_id    = aws_apigatewayv2_api.webhook.id
  route_key = "POST /${local.webhook_endpoint}"
  target    = "integrations/${aws_apigatewayv2_integration.webhook.id}"
}

resource "aws_apigatewayv2_stage" "webhook" {
  lifecycle {
    ignore_changes = [
      // see bug https://github.com/terraform-providers/terraform-provider-aws/issues/12893
      default_route_settings,
      // not terraform managed
      deployment_id
    ]
  }

  api_id      = aws_apigatewayv2_api.webhook.id
  name        = "$default"
  auto_deploy = true
  dynamic "access_log_settings" {
    for_each = var.webhook_lambda_apigateway_access_log_settings[*]
    content {
      destination_arn = access_log_settings.value.destination_arn
      format          = access_log_settings.value.format
    }
  }
  tags = local.tags
}

resource "aws_apigatewayv2_integration" "webhook" {
  lifecycle {
    ignore_changes = [
      // not terraform managed
      passthrough_behavior
    ]
  }

  api_id           = aws_apigatewayv2_api.webhook.id
  integration_type = "AWS_PROXY"

  connection_type      = "INTERNET"
  description          = "GitHub App webhook for receiving build events."
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.webhook.invoke_arn
  timeout_milliseconds = 30000
}


output "gateway" {
  value = aws_apigatewayv2_api.webhook
}

output "lambda" {
  value = aws_lambda_function.webhook
}

output "role" {
  value = aws_iam_role.webhook_lambda
}

output "endpoint_relative_path" {
  value = local.webhook_endpoint
}

output "gateway_api_endpoint" {
  value = aws_apigatewayv2_api.webhook.api_endpoint
}

output "gateway_execution_arn" {
  value = aws_apigatewayv2_api.webhook.execution_arn
}

output "gateway_arn" {
  value = aws_apigatewayv2_api.webhook.arn
}

output "gateway_id" {
  value = aws_apigatewayv2_api.webhook.id
}
