locals {
  tags = {
    Name        = "${var.stack_name}-${var.prefix}-ssm"
    Environment = terraform.workspace
  }
}

resource "aws_ssm_parameter" "github_app_id" {
  name  = "/actions_runner/${var.stack_name}-${var.prefix}/github_app_id"
  type  = "SecureString"
  value = var.github_app.id
  
  tags = local.tags
}

resource "aws_ssm_parameter" "github_app_key_base64" {
  name  = "/actions_runner/${var.stack_name}-${var.prefix}/github_app_key_base64"
  type  = "SecureString"
  value = var.github_app.key_base64
  
  tags = local.tags
}

resource "aws_ssm_parameter" "github_app_webhook_secret" {
  name  = "/actions_runner/${var.stack_name}-${var.prefix}/github_app_webhook_secret"
  type  = "SecureString"
  value = var.github_app.webhook_secret
  
  tags = local.tags
}


output "github_app_webhook_secret_arn" {
  value = aws_ssm_parameter.github_app_webhook_secret.arn
}

output "github_app_webhook_secret_name" {
  value = aws_ssm_parameter.github_app_webhook_secret.name
}

output "github_app_key_base64_name" {
  value = aws_ssm_parameter.github_app_key_base64.name
}

output "github_app_key_base64_arn" {
  value = aws_ssm_parameter.github_app_key_base64.arn
}

output "github_app_id_name" {
  value = aws_ssm_parameter.github_app_id.name
}

output "github_app_id_arn" {
  value = aws_ssm_parameter.github_app_id.arn
}